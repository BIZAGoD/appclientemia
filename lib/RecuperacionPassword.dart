import 'package:appcliente/CodeVerficacion.dart';
import 'package:flutter/material.dart';
import 'package:appcliente/PantallaInicio.dart';

class Recuperacionpassword extends StatelessWidget {
  const Recuperacionpassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
     
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Recuperación de Contraseña',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:  Color.fromARGB(255, 183, 17, 17),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Por favor ingresa tu correo electrónico para recibir instrucciones para recuperar tu contraseña.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 46, 5, 82)),
                labelStyle: const TextStyle(color: Color.fromARGB(255, 46, 5, 82)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82), width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                // Al presionar el botón, navegar a la pantalla de verificación de código
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CodeVerificacion()), // Navegar a CodVerificacion
                );
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 183, 17, 17),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Continuar'),
            ),
            const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaInicio()),
                ),
                
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Regresar"),
              ),            
          ],
        ),
      ),
    );
  }
}


