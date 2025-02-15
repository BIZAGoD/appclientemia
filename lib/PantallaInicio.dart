import 'dart:convert';
import 'package:appcliente/PantallaVerificado.dart';
import 'package:appcliente/RecuperacionPassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PantallaRegistro.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  String? emailError;
  String? claveError;
  bool _obscureText = true; // Controla la visibilidad de la contraseña

  Future<void> login() async {
    const String apiUrl = "https://followcar-api-railway-production.up.railway.app/api/usuarios";

    if (emailController.text.isEmpty || claveController.text.isEmpty) {
      setState(() {
        emailError = emailController.text.isEmpty ? "Ingrese un correo" : null;
        claveError = claveController.text.isEmpty ? "Ingrese una contraseña" : null;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> usuarios = json.decode(response.body);

        var usuarioEncontrado = usuarios.firstWhere(
          (usuario) =>
              usuario["Email"].toString().toLowerCase() == emailController.text.toLowerCase() &&
              usuario["Clave"] == claveController.text,
          orElse: () => null,
        );

        if (usuarioEncontrado != null) {
          setState(() {
            emailError = null;
            claveError = null;
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Pantallaverificado()),
          );
        } else {
          setState(() {
            emailError = "Correo o contraseña incorrectos";
            claveError = "Correo o contraseña incorrectos";
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al conectar con la API")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ocurrió un error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logohome.png',
                    height: 200,
                    width: 300,
                    fit: BoxFit.contain,
                  ),
                ),
                const Text(
                  'Bienvenido de vuelta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 183, 17, 17),
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 46, 5, 82)),
                    errorText: emailError,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: claveController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 46, 5, 82)),
                    errorText: claveError,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Recuperacionpassword()),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Color.fromARGB(255, 46, 5, 82), fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 183, 17, 17),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    "Inicio de sesión",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: const Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(color: Color.fromARGB(255, 46, 5, 82), fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
