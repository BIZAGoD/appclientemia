import 'package:appcliente/Pantallas/Servicios/PantallaAgregarTaller.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaServicioAgendado.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PantallaAgendarServicio extends StatefulWidget {
  final Taller taller;

  const PantallaAgendarServicio({super.key, required this.taller});

  @override
  _PantallaAgendarServicioState createState() => _PantallaAgendarServicioState();
}

class _PantallaAgendarServicioState extends State<PantallaAgendarServicio> {
  TextEditingController fechaController = TextEditingController();
  TextEditingController horaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  String? selectedTipoServicio;

  Future<void> agendarServicio() async {
    final url = Uri.parse('https://followcar-api-railway-production.up.railway.app/api/citas');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'ClienteId': 1, // Suponiendo que el cliente tiene ID 1
        'VehiculoId': 1, // Suponiendo que el vehículo tiene ID 1
        'TipoServicioId': selectedTipoServicio, // Deberías mapear el servicio seleccionado
        'MecanicoId': 1, // Suponiendo que el mecánico tiene ID 1
        'FechaHora': '${fechaController.text} ${horaController.text}', // Fecha y hora concatenadas
        'Estado': 'Pendiente',
        'MotivoCancelacion': '',
        'ObservacionesCliente': descripcionController.text,
        'ObservacionesInternas': descripcionController.text,
        'Prioridad': 'Alta',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Servicio agendado exitosamente')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaServicioAgendado()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agendar el servicio')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Servicio'),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agendar Servicio para: ${widget.taller.nombre}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 46, 5, 82),
                ),
              ),
              const SizedBox(height: 20),

              // Campo para seleccionar la fecha
              TextFormField(
                controller: fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha del Servicio',
                  hintText: 'Selecciona la fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  // Aquí puedes agregar un selector de fecha
                },
              ),
              const SizedBox(height: 20),

              // Campo para descripción del servicio
              TextFormField(
                controller: descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción del Servicio',
                  hintText: 'Especifica el servicio requerido',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Selector de tipo de servicio
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo de Servicio',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.build),
                ),
                items: [
                  DropdownMenuItem(
                    value: '1', // ID para Cambio de Aceite
                    child: Text('Cambio de Aceite'),
                  ),
                  DropdownMenuItem(
                    value: '2', // ID para Revisión General
                    child: Text('Revisión General'),
                  ),
                  DropdownMenuItem(
                    value: '3', // ID para Frenos
                    child: Text('Frenos'),
                  ),
                  DropdownMenuItem(
                    value: '4', // ID para Alineación
                    child: Text('Alineación'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedTipoServicio = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Campo para seleccionar la hora
              TextFormField(
                controller: horaController,
                decoration: InputDecoration(
                  labelText: 'Hora del Servicio',
                  hintText: 'Selecciona la hora',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () async {
                  // Aquí puedes agregar un selector de hora
                },
              ),
              const SizedBox(height: 30),

              // Botón para confirmar el agendado
              ElevatedButton(
                onPressed: agendarServicio,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 237, 83, 65),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmar Agendado',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
