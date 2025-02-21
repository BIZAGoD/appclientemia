import 'package:flutter/material.dart';
import 'package:appcliente/PantallaInicio.dart'; // Asegúrate de importar la pantalla de inicio
import 'package:shared_preferences/shared_preferences.dart'; // Para manejar la sesión


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
        return WillPopScope(
          onWillPop: () async => false, // Deshabilita retroceso
          child: AlertDialog(
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
                onPressed: () async {
                  try {
                    // Limpiar todos los datos del usuario
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    
                    // Limpieza específica de datos del usuario
                    await prefs.remove('nombre');
                    await prefs.remove('apellido');
                    await prefs.remove('telefono');
                    await prefs.remove('correo');
                    await prefs.remove('userId');
                    await prefs.remove('userToken');
                    await prefs.remove('imagenPerfil');
                    // Limpia el resto de las preferencias por si acaso
                    await prefs.clear();

                    // Navegar a la pantalla de inicio y limpiar la pila de navegación
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const PantallaInicio()), 
                        (Route<dynamic> route) => false,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error al cerrar sesión. Intente nuevamente.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
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
          ),
        );
      },
    );
  }
}
