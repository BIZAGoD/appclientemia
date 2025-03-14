import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'PantallaRegistroExito.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

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

  String? nombreError;
  String? apellidoError;
  String? telefonoError;
  String? emailError;
  String? passwordError;
  bool _isPasswordVisible = false;

  List<Map<String, dynamic>> usuariosExistentes = [];

  @override
  void initState() {
    super.initState();
    // Cargar usuarios en segundo plano sin bloquear la interfaz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cargarUsuarios();
    });
  }

  Future<void> cargarUsuarios() async {
    try {
      usuariosExistentes = await ApiService.obtenerUsuarios();
    } catch (e) {
      // Manejo silencioso del error, sin mostrar SnackBar
      print('Error al cargar usuarios: ${e.toString()}');
      // Inicializamos la lista como vacía para evitar errores
      usuariosExistentes = [];
    }
  }

  Future<void> registrarUsuario() async {
    final String nombre = nombreController.text.trim();
    final String apellido = apellidoController.text.trim();
    final String telefono = telefonoController.text.trim();
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // Reiniciar errores
    setState(() {
      nombreError = null;
      apellidoError = null;
      telefonoError = null;
      emailError = null;
      passwordError = null;
    });

    // Validaciones locales sin depender de la API
    // Omitimos la validación de datos existentes si no pudimos cargar los usuarios
    if (usuariosExistentes.isNotEmpty) {
      bool datosExistentes = false;

      // Validar si el correo ya existe
      if (usuariosExistentes.any((user) => user['Email'].toString().toLowerCase() == email.toLowerCase())) {
        setState(() {
          emailError = 'Este correo electrónico ya está registrado';
        });
        datosExistentes = true;
      }

      // Validar si el teléfono ya existe
      if (usuariosExistentes.any((user) => user['Telefono'] == telefono)) {
        setState(() {
          telefonoError = 'Este número de teléfono ya está registrado';
        });
        datosExistentes = true;
      }

      if (datosExistentes) {
        return;
      }
    }

    // Validación de nombre
    final RegExp nombreRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nombreRegex.hasMatch(nombre)) {
      nombreError = 'El nombre solo debe contener letras';
    } else if (nombre.length > 20) {
      nombreError = 'El nombre no puede tener más de 20 caracteres';
    }

    // Validación de apellido
    final RegExp apellidoRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!apellidoRegex.hasMatch(apellido)) {
      apellidoError = 'El apellido solo debe contener letras';
    }

    // Validación de teléfono
    final RegExp telefonoRegex = RegExp(r'^[0-9]+$');
    if (!telefonoRegex.hasMatch(telefono)) {
      telefonoError = 'El teléfono solo debe contener números';
    }

    // Validación de correo electrónico
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      emailError = 'Por favor, ingresa un correo electrónico válido';
    }

    // Validación de contraseña
    if (password.length < 6) {
      passwordError = 'La contraseña debe tener al menos 6 caracteres';
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(password)) {
      passwordError = 'La contraseña debe contener letras y números';
    }

    // Actualizar el estado para mostrar los errores
    setState(() {});

    // Si hay errores, no continuar
    if (nombreError != null || apellidoError != null || telefonoError != null || emailError != null || passwordError != null) {
      return;
    }

    if (nombre.isEmpty || apellido.isEmpty || telefono.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    try {
      final Map<String, dynamic> userData = {
        'Nombre': nombre,
        'Apellido': apellido,
        'Telefono': telefono,
        'Email': email,
        'Clave': password,
        'Imagen': null,
      };

      // Intentamos registrar al usuario con manejo de errores mejorado
      try {
        final resultado = await ApiService.registrarUsuario(userData);
        
        if (!mounted) return;

        if (resultado['success']) {
          // Guardar datos del usuario en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', nombre);
          await prefs.setString('lastName', apellido);
          await prefs.setString('email', email);
          await prefs.setString('phone', telefono);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Pantallaregistroexito()),
          );
        } else {
          // Mostrar un mensaje más amigable
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo completar el registro. Por favor, inténtalo más tarde.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        // Mostrar un mensaje más amigable sin detalles técnicos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo conectar con el servidor. Por favor, verifica tu conexión a internet e inténtalo más tarde.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado. Por favor, inténtalo más tarde.')),
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
                        'assets/logoapphome.webp',
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
                  _buildTextField(nombreController, 'Nombre', Icons.person, errorText: nombreError),
                  const SizedBox(height: 16),
                  _buildTextField(apellidoController, 'Apellido', Icons.person_outline, errorText: apellidoError),
                  const SizedBox(height: 16),
                  _buildTextField(telefonoController, 'Teléfono', Icons.phone, isNumber: true, errorText: telefonoError),
                  const SizedBox(height: 16),
                  _buildTextField(emailController, 'Correo Electrónico', Icons.email, errorText: emailError),
                  const SizedBox(height: 16),
                  _buildTextField(passwordController, 'Contraseña', Icons.lock, isPassword: true, errorText: passwordError),
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
      {bool isPassword = false, bool isNumber = false, String? errorText}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      inputFormatters: label == 'Nombre' 
          ? [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'))]
          : null,
      onChanged: label == 'Nombre' ? (value) {
        if (value.length > 20 && nombreError == null) {
          setState(() {
            nombreError = 'El nombre no puede tener más de 20 caracteres';
          });
        } else if (value.length <= 20 && nombreError == 'El nombre no puede tener más de 20 caracteres') {
          setState(() {
            nombreError = null;
          });
        }
      } : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 46, 5, 82)),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 46, 5, 82)),
        errorText: errorText,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color.fromARGB(255, 46, 5, 82),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
