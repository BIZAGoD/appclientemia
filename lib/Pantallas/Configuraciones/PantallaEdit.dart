import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appcliente/Pantallas/Configuraciones/PerfilActualizado.dart';

class PantallaEdit extends StatefulWidget {
  final String userName;
  final String userEmail;

  const PantallaEdit({super.key, required this.userName, required this.userEmail});

  @override
  _PantallaEditState createState() => _PantallaEditState();
}

class _PantallaEditState extends State<PantallaEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? widget.userName;
      _lastNameController.text = prefs.getString('lastName') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? userId = prefs.getInt('userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró el ID del usuario')),
      );
      return;
    }

    String userIdString = userId.toString();
    String apiUrl = 'https://followcar-api-railway-production.up.railway.app/api/usuarios/$userIdString';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'Nombre': _nameController.text,
      'Apellido': _lastNameController.text,
      'Email': widget.userEmail,
      'Telefono': _phoneController.text,
      'Clave': _passwordController.text,
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        await prefs.setString('name', _nameController.text);
        await prefs.setString('lastName', _lastNameController.text);
        await prefs.setString('phone', _phoneController.text);
        await prefs.setString('password', _passwordController.text);

        // Redirigir a la pantalla PerfilActualizado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaDatosActualizados()), 
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color naranjaColor = Color.fromARGB(255, 237, 83, 65);
    final Color purpuraColor = Color.fromARGB(255, 46, 5, 82);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editar Perfil', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            fontSize: 22,
          )
        ),
        backgroundColor: naranjaColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color.fromARGB(255, 237, 83, 65),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 30),
              buildTextField(
                _nameController, 
                'Nombre',
                naranjaColor,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              buildTextField(
                _lastNameController, 
                'Apellido',
                naranjaColor,
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  enabled: false,
                  controller: TextEditingController(text: widget.userEmail),
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: naranjaColor),
                    prefixIcon: Icon(Icons.email_outlined, color: naranjaColor),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: naranjaColor.withOpacity(0.3)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: naranjaColor.withOpacity(0.3)),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildTextField(
                _phoneController, 
                'Teléfono',
                naranjaColor,
                Icons.phone_outlined,
              ),
              const SizedBox(height: 20),
              buildTextField(
                _passwordController, 
                'Contraseña',
                naranjaColor,
                Icons.lock_outline,
                isPassword: true,
                showEyeIcon: true,
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purpuraColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String label,
    Color primaryColor,
    IconData icon, {
    bool isPassword = false,
    bool showEyeIcon = false,
  }) {
    bool _obscureText = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: _obscureText,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: primaryColor),
              prefixIcon: Icon(icon, color: primaryColor),
              suffixIcon: showEyeIcon 
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        );
      }
    );
  }
}
