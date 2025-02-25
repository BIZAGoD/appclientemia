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

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
    try {
      // First try to get data from API
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
        // Get the most recent vehicle data
        if (citas.isNotEmpty) {
          final citaMasReciente = citas.reduce((a, b) {
            final fechaA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1900);
            final fechaB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1900);
            return fechaA.isAfter(fechaB) ? a : b;
          });
          
          if (citaMasReciente != null) {
            setState(() {
              _modeloController.text = citaMasReciente['Modelo']?.toString() ?? '';
              _marcaController.text = citaMasReciente['Marca']?.toString() ?? '';
              _anioController.text = citaMasReciente['Anio']?.toString() ?? '';
              _placasController.text = citaMasReciente['Placas']?.toString() ?? '';
              _hasVehicle = _placasController.text.isNotEmpty;
              _isLoading = false;
            });

            // Update local storage with API data
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('modelo', _modeloController.text);
            await prefs.setString('marca', _marcaController.text);
            await prefs.setString('anio', _anioController.text);
            await prefs.setString('placas', _placasController.text);
            return;
          }
        }
      }

      // Fallback to local storage if API fails or returns no data
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await _guardarDatos();

    final Map<String, dynamic> citaData = {
      "Modelo": _modeloController.text,
      "Marca": _marcaController.text,
      "Anio": _anioController.text,
      "Placas": _placasController.text,
      "FechaCita": _fechaController.text,
    };

    final url = Uri.parse(
        "https://followcar-api-railway-production.up.railway.app/api/citasClientes");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: json.encode(citaData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PantallaCitaAgendada()),
        );
      } else {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarVehiculo() async {
    try {
      if (_placasController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No hay placas identificadas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Primero necesitamos obtener el ID de la cita basado en las placas
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
        final cita = citas.firstWhere(
          (cita) => cita['Placas'] == _placasController.text,
          orElse: () => null,
        );

        if (cita == null) {
          throw Exception('No se encontró la cita con esas placas');
        }

        final citaId = cita['id'].toString();

        final Map<String, dynamic> citaData = {
          "Modelo": _modeloController.text,
          "Marca": _marcaController.text,
          "Anio": _anioController.text,
          "Placas": _placasController.text,
          "FechaCita": _fechaController.text,
        };

        final urlUpdate = Uri.parse(
            "https://followcar-api-railway-production.up.railway.app/api/citasClientes/$citaId");

        final response = await http.put(
          urlUpdate,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: json.encode(citaData),
        );

        if (response.statusCode == 204) {
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
          throw Exception('Error al actualizar la cita');
        }
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
      if (_placasController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No hay placas identificadas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Primero necesitamos obtener el ID de la cita basado en las placas
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
        final cita = citas.firstWhere(
          (cita) => cita['Placas'] == _placasController.text,
          orElse: () => null,
        );

        if (cita == null) {
          throw Exception('No se encontró la cita con esas placas');
        }

        final citaId = cita['id'].toString();

        final urlDelete = Uri.parse(
            "https://followcar-api-railway-production.up.railway.app/api/citasClientes/$citaId");

        final response = await http.delete(
          urlDelete,
          headers: {
            "Accept": "application/json",
          },
        );

        if (response.statusCode == 204) {
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
          throw Exception('Error al eliminar la cita');
        }
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
        : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Datos del Vehículo'),
                if (_hasVehicle) ...[
                  _buildReadOnlyField('Modelo del Vehículo', _modeloController.text),
                  _buildReadOnlyField('Marca del Vehículo', _marcaController.text),
                  _buildReadOnlyField('Año del Vehículo', _anioController.text),
                  _buildReadOnlyField('Placas del Vehículo', _placasController.text),
                  
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _editarVehiculo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Editar Vehículo', 
                            style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _eliminarVehiculo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('Eliminar Vehículo', 
                            style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo del Vehículo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value!.isEmpty ? 'Ingrese el modelo' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca del Vehículo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value!.isEmpty ? 'Ingrese la marca' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _anioController,
                    decoration: const InputDecoration(
                      labelText: 'Año del Vehículo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value!.isEmpty ? 'Ingrese el año' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _placasController,
                    decoration: const InputDecoration(
                      labelText: 'Placas del Vehículo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value!.isEmpty ? 'Ingrese las placas' : null,
                  ),
                ],

                const SizedBox(height: 20),
                TextFormField(
                  controller: _fechaController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de la Cita',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _seleccionarFecha,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Seleccione una fecha' : null,
                ),

                const SizedBox(height: 25),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agendarCita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 237, 83, 65),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Agendar',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String labelText, String value) {
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
            color: Colors.deepPurple.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                _getIconForField(labelText),
                color: Colors.deepPurple,
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

  IconData _getIconForField(String labelText) {
    switch (labelText) {
      case 'Modelo del Vehículo':
        return Icons.directions_car;
      case 'Marca del Vehículo':
        return Icons.branding_watermark;
      case 'Año del Vehículo':
        return Icons.calendar_today;
      case 'Placas del Vehículo':
        return Icons.credit_card;
      default:
        return Icons.info;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }
}
