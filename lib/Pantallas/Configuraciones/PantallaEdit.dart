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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Editar Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 237, 83, 65),
              ),
              child: const Text('Guardar cambios', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
