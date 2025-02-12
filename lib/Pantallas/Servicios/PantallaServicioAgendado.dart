import 'package:flutter/material.dart';

class PantallaServicioAgendado extends StatelessWidget {
  const PantallaServicioAgendado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicio Agendado'),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de la pantalla
            Text(
              '¡Servicio Agendado Exitosamente!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 5, 82),
              ),
            ),
            const SizedBox(height: 20),

            // Detalle del servicio agendado
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detalles del Servicio:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tipo de Servicio: Cambio de Aceite', // Aquí puedes agregar dinámicamente el tipo de servicio
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Fecha y Hora: 2025-01-29 10:00 AM', // Aquí puedes agregar dinámicamente la fecha y hora
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Mecánico Asignado: Juan Pérez', // Aquí puedes agregar dinámicamente el nombre del mecánico
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Observaciones: Cliente no se presentó', // Aquí puedes agregar dinámicamente las observaciones
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para volver a la pantalla anterior o hacer otra acción
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Regresar a la pantalla anterior
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 237, 83, 65),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Volver a la Pantalla Principal',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
