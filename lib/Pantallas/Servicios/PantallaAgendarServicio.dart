import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appcliente/Pantallas/Citas/PantallaCitaAgendada.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaAgendarServicio extends StatefulWidget {
  const PantallaAgendarServicio({super.key});

  @override
  _PantallaAgendarServicioState createState() => _PantallaAgendarServicioState();
}

class _PantallaAgendarServicioState extends State<PantallaAgendarServicio> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _placasController = TextEditingController();
  bool _hasVehicle = false;
  bool _isLoading = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _cargarDatosGuardados();
    if (!_hasVehicle) {
      _solicitarDatosVehiculo();
    }
  }

  Future<void> _getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('userEmail') ?? 'usuario@ejemplo.com';
    });
  }

  Future<void> _cargarDatosGuardados() async {
    try {
      if (_userEmail == null) {
        throw Exception('Email de usuario no encontrado');
      }

      final urlGet = Uri.parse(
          "https://followcar-api-railway-production.up.railway.app/api/citasClientes");
      
      final responseGet = await http.get(
        urlGet,
        headers: {
          "Accept": "application/json",
        },
      );

      if (responseGet.statusCode == 200) {
        final List<dynamic> citas = json.decode(responseGet.body);
        // Filtrar citas por el email del usuario actual
        final citasUsuario = citas.where((cita) => 
          cita['Email']?.toString() == _userEmail
        ).toList();
        
        if (citasUsuario.isNotEmpty) {
          final citaMasReciente = citasUsuario.reduce((a, b) {
            final fechaA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
            final fechaB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
            return fechaA.isAfter(fechaB) ? a : b;
          });
          
          setState(() {
            _modeloController.text = citaMasReciente['Modelo']?.toString() ?? '';
            _marcaController.text = citaMasReciente['Marca']?.toString() ?? '';
            _anioController.text = citaMasReciente['Anio']?.toString() ?? '';
            _placasController.text = citaMasReciente['Placas']?.toString() ?? '';
            _hasVehicle = _placasController.text.isNotEmpty;
            _isLoading = false;
          });

          await _guardarDatos();
          return;
        }
      }

      // Fallback a datos locales
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _modeloController.text = prefs.getString('modelo') ?? '';
        _marcaController.text = prefs.getString('marca') ?? '';
        _anioController.text = prefs.getString('anio') ?? '';
        _placasController.text = prefs.getString('placas') ?? '';
        _hasVehicle = _placasController.text.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      print('Error en _cargarDatosGuardados: $e');
      setState(() {
        _isLoading = false;
        _hasVehicle = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('modelo', _modeloController.text);
    await prefs.setString('marca', _marcaController.text);
    await prefs.setString('anio', _anioController.text);
    await prefs.setString('placas', _placasController.text);
  }

  void _seleccionarFecha() async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (fechaSeleccionada != null) {
      setState(() {
        _fechaController.text = 
            "${fechaSeleccionada.day.toString().padLeft(2, '0')}-"
            "${fechaSeleccionada.month.toString().padLeft(2, '0')}-"
            "${fechaSeleccionada.year}";
      });
    }
  }

  Future<void> _agendarCita() async {
    try {
      if (!_formKey.currentState!.validate()) {
        print('Formulario no válido');
        return;
      }

      // Verificar que todos los campos requeridos estén llenos
      if (_fechaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor seleccione una fecha para la cita'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await _guardarDatos();

      final Map<String, dynamic> citaData = {
        "Email": _userEmail,
        "Modelo": _modeloController.text,
        "Marca": _marcaController.text,
        "Anio": _anioController.text,
        "Placas": _placasController.text,
        "FechaCita": _fechaController.text,
      };

      print('Datos a enviar: $citaData'); // Debug print

      final url = Uri.parse(
          "https://followcar-api-railway-production.up.railway.app/api/citasClientes");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(citaData),
      );

      print('Código de respuesta: ${response.statusCode}'); // Debug print
      print('Respuesta del servidor: ${response.body}'); // Debug print

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PantallaCitaAgendada()),
        );
      } else {
        if (!mounted) return;
        
        Map<String, dynamic> errorResponse = json.decode(response.body);
        String errorMessage = errorResponse['message'] ?? 'Error al agendar la cita. Inténtelo de nuevo.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error en _agendarCita: $e'); // Debug print
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al agendar la cita: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _editarVehiculo() async {
    try {
      if (_userEmail == null) {
        throw Exception('Email de usuario no encontrado');
      }

      if (_placasController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No hay placas identificadas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final Map<String, dynamic> citaData = {
        "Email": _userEmail,
        "Modelo": _modeloController.text,
        "Marca": _marcaController.text,
        "Anio": _anioController.text,
        "Placas": _placasController.text,
        "FechaCita": _fechaController.text.isEmpty ? null : _fechaController.text,
      };

      final urlUpdate = Uri.parse(
          "https://followcar-api-railway-production.up.railway.app/api/citasClientes/${Uri.encodeComponent(_userEmail!)}");

      print('URL de actualización: $urlUpdate'); // Debug
      print('Datos a actualizar: $citaData'); // Debug

      final response = await http.put(
        urlUpdate,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(citaData),
      );

      print('Código de respuesta: ${response.statusCode}'); // Debug
      print('Cuerpo de respuesta: ${response.body}'); // Debug

      if (response.statusCode == 200 || response.statusCode == 204) {
        await _guardarDatos();
        setState(() {
          _hasVehicle = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al actualizar la cita. Código: ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error en _editarVehiculo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _eliminarVehiculo() async {
    try {
      if (_userEmail == null) {
        throw Exception('Email de usuario no encontrado');
      }

      final urlDelete = Uri.parse(
          "https://followcar-api-railway-production.up.railway.app/api/citasClientes/${Uri.encodeComponent(_userEmail!)}");

      print('URL de eliminación: $urlDelete'); // Debug

      final response = await http.delete(
        urlDelete,
        headers: {
          "Accept": "application/json",
        },
      );

      print('Código de respuesta eliminación: ${response.statusCode}'); // Debug
      print('Cuerpo de respuesta eliminación: ${response.body}'); // Debug

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Limpiar datos locales
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('modelo');
        await prefs.remove('marca');
        await prefs.remove('anio');
        await prefs.remove('placas');
        
        setState(() {
          _modeloController.clear();
          _marcaController.clear();
          _anioController.clear();
          _placasController.clear();
          _hasVehicle = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehículo eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error al eliminar la cita. Código: ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error en _eliminarVehiculo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _solicitarDatosVehiculo() {
    // Aquí puedes mostrar un diálogo o un formulario para que el usuario ingrese los datos del vehículo
    // Por ejemplo, puedes usar un showDialog o un BottomSheet para solicitar los datos
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _modeloController.dispose();
    _marcaController.dispose();
    _anioController.dispose();
    _placasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Nueva Cita',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 46, 5, 82),
                Color.fromARGB(255, 237, 83, 65),
              ],
            ),
          ),
        ),
      ),
      
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                const Color.fromARGB(255, 246, 241, 251).withOpacity(0.5),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Datos de su Vehículo'),
                    const SizedBox(height: 20),
                    if (_hasVehicle) ...[
                      _buildReadOnlyField('Modelo del Vehículo', _modeloController.text, Icons.directions_car),
                      _buildReadOnlyField('Marca del Vehículo', _marcaController.text, Icons.branding_watermark),
                      _buildReadOnlyField('Año del Vehículo', _anioController.text, Icons.calendar_today),
                      _buildReadOnlyField('Placas del Vehículo', _placasController.text, Icons.credit_card),
                      
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              onPressed: _editarVehiculo,
                              icon: Icons.edit_outlined,
                              label: 'Editar Vehículo',
                              color: const Color.fromARGB(255, 46, 5, 82),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildActionButton(
                              onPressed: _eliminarVehiculo,
                              icon: Icons.delete_outline,
                              label: 'Eliminar Vehículo',
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildFormField(
                        controller: _modeloController,
                        label: 'Modelo del Vehículo',
                        icon: Icons.directions_car,
                        hint: 'Ingrese el modelo',
                      ),
                      const SizedBox(height: 15),
                      _buildFormField(
                        controller: _marcaController,
                        label: 'Marca del Vehículo',
                        icon: Icons.branding_watermark,
                        hint: 'Ingrese la marca',
                      ),
                      const SizedBox(height: 15),
                      _buildFormField(
                        controller: _anioController,
                        label: 'Año del Vehículo',
                        icon: Icons.calendar_today,
                        hint: 'Ingrese el año',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),
                      _buildFormField(
                        controller: _placasController,
                        label: 'Placas del Vehículo',
                        icon: Icons.credit_card,
                        hint: 'Ingrese las placas',
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                    const SizedBox(height: 25),
                    _buildFormField(
                      controller: _fechaController,
                      label: 'Fecha de la Cita',
                      icon: Icons.event,
                      hint: 'Seleccione una fecha',
                      readOnly: true,
                      onTap: _seleccionarFecha,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Color.fromARGB(255, 46, 5, 82),
                        ),
                        onPressed: _seleccionarFecha,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildMainActionButton(
                      onPressed: _agendarCita,
                      label: 'Agendar Cita',
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildReadOnlyField(String labelText, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: const Color.fromARGB(255, 46, 5, 82),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 46, 5, 82),
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 46, 5, 82),
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        validator: (value) => value!.isEmpty ? 'Este campo es requerido' : null,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildMainActionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 46, 5, 82),
            Color.fromARGB(255, 237, 83, 65),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 237, 83, 65).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 46, 5, 82),
        ),
      ),
    );
  }
}
