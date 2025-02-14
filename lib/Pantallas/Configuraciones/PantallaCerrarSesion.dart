import 'package:flutter/material.dart';
import 'package:appcliente/PantallaInicio.dart'; // Asegúrate de importar la pantalla de inicio

class PantallaCerrarSesion extends StatelessWidget {
  const PantallaCerrarSesion({super.key});

  @override
  Widget build(BuildContext context) {
    // Mostrar la alerta automáticamente cuando la pantalla se construye
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarConfirmacionCerrarSesion(context);
    });

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Cambia el color del ícono del drawer
      ),
      body: const Center(), // No necesitamos contenido en el body
    );
  }

  // Método para mostrar el cuadro de diálogo de confirmación
  void _mostrarConfirmacionCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que el cuadro de diálogo se cierre al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0), // Bordes redondeados
          ),
          backgroundColor: Colors.white, // Fondo blanco
          title: const Text(
            '¿Deseas cerrar sesión?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Si cierras sesión, perderás el acceso hasta que inicies nuevamente.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el cuadro de diálogo
                Navigator.pop(context); // Regresar al Drawer
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PantallaInicio(), // Navegar a la pantalla de inicio
                  ),
                );
              },
              child: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
