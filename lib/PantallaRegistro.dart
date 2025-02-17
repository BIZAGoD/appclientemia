import 'package:appcliente/PantallaRegistroExito.dart';
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registrarUsuario() async {
    final String nombre = nombreController.text;
    final String apellido = apellidoController.text;
    final String telefono = telefonoController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrando usuario...')),
    );

    final resultado = await ApiService.registrarUsuario(
        nombre, apellido, telefono, email, password);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['success']
            ? 'Usuario registrado correctamente'
            : 'Error: ${resultado['message']}')),
      );

      if (resultado['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Pantallaregistroexito()),
        );
      }
    }

    print('Resultado del registro: $resultado');
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
        child: SafeArea( // Evita que los elementos queden bajo la barra de estado
          child: SingleChildScrollView( // Permite desplazamiento en caso de falta de espacio
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 200, // Mantiene la imagen con tamaño fijo
                    child: Image.asset(
                      'assets/logohome.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Text(
                    'Regístrate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 183, 17, 17),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                      controller: nombreController,
                      decoration: _buildInputDecoration('Nombre', Icons.person)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: apellidoController,
                      decoration: _buildInputDecoration('Apellido', Icons.person_outline)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: telefonoController,
                      decoration: _buildInputDecoration('Teléfono', Icons.phone)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: emailController,
                      decoration: _buildInputDecoration('Correo Electrónico', Icons.email)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Contraseña', Icons.lock)),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: registrarUsuario,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 183, 17, 17),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text("Registrarse"),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text("Regresar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color.fromARGB(255, 46, 5, 82)),
      labelStyle: const TextStyle(color: Color.fromARGB(255, 46, 5, 82)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82), width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }
}
