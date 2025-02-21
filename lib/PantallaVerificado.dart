import 'package:appcliente/Pantallas/Servicios/PantallaHomeServicios.dart';
import 'package:flutter/material.dart';

class Pantallaverificado extends StatelessWidget {
  const Pantallaverificado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Center(
                child: Image.asset(
                  'assets/verify3.webp',
                  height: 225,
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const Text(
                'Verificacion Exitosa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,  
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                '!!Bienvenido!!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 32, 31, 31),
                ),
              ),
              const SizedBox(height: 32),

               ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaHomeservicios()),
                  );
                  // Acción al presionar el botón
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 247, 247, 247), 
                  backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Continuar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}