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
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _placasController = TextEditingController();
  final TextEditingController _serviciosController = TextEditingController();

  bool _datosGuardados = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
  }

  Future<void> _cargarDatosGuardados() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombreController.text = prefs.getString('nombre') ?? '';
      _apellidosController.text = prefs.getString('apellidos') ?? '';
      _telefonoController.text = prefs.getString('telefono') ?? '';
      _correoController.text = prefs.getString('correo') ?? '';
      _modeloController.text = prefs.getString('modelo') ?? '';
      _marcaController.text = prefs.getString('marca') ?? '';
      _anioController.text = prefs.getString('anio') ?? '';
      _placasController.text = prefs.getString('placas') ?? '';
      
      // Verificar si ya hay datos guardados
      _datosGuardados = prefs.getString('nombre')?.isNotEmpty ?? false;
    });
  }

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', _nombreController.text);
    await prefs.setString('apellidos', _apellidosController.text);
    await prefs.setString('telefono', _telefonoController.text);
    await prefs.setString('correo', _correoController.text);
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
    // Validar solo el campo de fecha si los datos ya están guardados
    if (_datosGuardados) {
      if (_fechaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor seleccione una fecha para la cita'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      // Validar todos los campos si es la primera vez
      if (!_formKey.currentState!.validate()) {
        return;
      }
      await _guardarDatos();
    }

    final Map<String, dynamic> citaData = {
      "Nombre": _nombreController.text,
      "Apellido": _apellidosController.text,
      "Telefono": _telefonoController.text,
      "Email": _correoController.text,
      "Modelo": _modeloController.text,
      "Marca": _marcaController.text,
      "Anio": _anioController.text,
      "Placas": _placasController.text,
      "FechaCita": _fechaController.text,
      "Servicios": _serviciosController.text,
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

  @override
  void dispose() {
    _fechaController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    _modeloController.dispose();
    _marcaController.dispose();
    _anioController.dispose();
    _placasController.dispose();
    _serviciosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Agendar nueva cita',
            style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_datosGuardados) ...[
                  _buildSectionTitle('Datos del Cliente'),
                  _buildTextField('Nombre del Cliente', _nombreController),
                  _buildTextField('Apellidos', _apellidosController),
                  _buildTextField('Teléfono de Contacto', _telefonoController,
                      keyboardType: TextInputType.phone),
                  _buildTextField('Correo Electrónico', _correoController,
                      keyboardType: TextInputType.emailAddress),

                  const SizedBox(height: 20),
                  _buildSectionTitle('Datos del Vehículo'),
                  _buildTextField('Modelo del Vehículo', _modeloController),
                  _buildTextField('Marca del Vehículo', _marcaController),
                  _buildTextField('Año del Vehículo', _anioController,
                      keyboardType: TextInputType.number),
                  _buildTextField('Placas del Vehículo', _placasController),
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
                    border: OutlineInputBorder(),
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
                          style: TextStyle(
                              fontSize: 18, color: Colors.white)),
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

  Widget _buildTextField(String labelText, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: (value) =>
            value!.isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
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
