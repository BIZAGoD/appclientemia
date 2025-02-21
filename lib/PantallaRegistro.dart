import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'PantallaRegistroExito.dart'; 

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
    final String nombre = nombreController.text.trim();
    final String apellido = apellidoController.text.trim();
    final String telefono = telefonoController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (nombre.isEmpty || apellido.isEmpty || telefono.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registrando usuario...')),
    );

    try {
      final Map<String, String> userData = {
        'Nombre': nombre,
        'Apellido': apellido,
        'Telefono': telefono,
        'Email': email,
        'Clave': password,
      };

      final resultado = await ApiService.registrarUsuario(userData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultado['success']
            ? 'Usuario registrado correctamente'
            : 'Error: ${resultado['message']}')),
      );

      if (resultado['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Pantallaregistroexito()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 300,
                      height: 150,
                      child: Image.asset(
                        'assets/logohome.webp',
                        fit: BoxFit.cover,
                      ),
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
                  _buildTextField(nombreController, 'Nombre', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(apellidoController, 'Apellido', Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildTextField(telefonoController, 'Teléfono', Icons.phone, isNumber: true),
                  const SizedBox(height: 16),
                  _buildTextField(emailController, 'Correo Electrónico', Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField(passwordController, 'Contraseña', Icons.lock, isPassword: true),
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

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 46, 5, 82)),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 46, 5, 82)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
