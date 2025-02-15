import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appcliente/Pantallas/Servicios/PantallaServicioAgendado.dart';

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
            "${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}";
      });
    }
  }

  Future<void> _agendarCita() async {
    final Map<String, dynamic> citaData = {
      "nombre": _nombreController.text,
      "apellidos": _apellidosController.text,
      "telefono": _telefonoController.text,
      "correo": _correoController.text,
      "modelo": _modeloController.text,
      "marca": _marcaController.text,
      "anio": _anioController.text,
      "placas": _placasController.text,
      "fecha": _fechaController.text,
      "servicios": _serviciosController.text,
    };

    final url = Uri.parse("https://followcar-api-railway-production.up.railway.app/api/citasClientes");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(citaData),
      );

      if (response.statusCode == 201) {
        // Cita agendada con éxito, navega a la pantalla de confirmación
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaServicioAgendado()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al agendar la cita. Inténtelo de nuevo.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Agendar nueva cita',style: TextStyle(fontSize: 18, color: Colors.white)),
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
                _buildSectionTitle('Datos del Cliente'),
                _buildTextField('Nombre del Cliente', _nombreController),
                _buildTextField('Apellidos', _apellidosController),
                _buildTextField('Teléfono de Contacto', _telefonoController, keyboardType: TextInputType.phone),
                _buildTextField('Correo Electrónico', _correoController, keyboardType: TextInputType.emailAddress),

                const SizedBox(height: 20),
                _buildSectionTitle('Datos del Vehículo'),
                _buildTextField('Modelo del Vehículo', _modeloController),
                _buildTextField('Marca del Vehículo', _marcaController),
                _buildTextField('Año del Vehículo', _anioController, keyboardType: TextInputType.number),
                _buildTextField('Placas del Vehículo', _placasController),

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
                ),

                const SizedBox(height: 25),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _agendarCita,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Agendar',style: TextStyle(fontSize: 18, color: Colors.white)),
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
      ),
    );
  }
}
