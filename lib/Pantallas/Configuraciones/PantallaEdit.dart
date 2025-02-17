import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaEdit extends StatefulWidget {
  final String userName;
  final String userEmail;

  const PantallaEdit({super.key, required this.userName, required this.userEmail});

  @override
  _PantallaEditState createState() => _PantallaEditState();
}

class _PantallaEditState extends State<PantallaEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userName;
    _emailController.text = widget.userEmail;
  }

  // Guardar cambios en SharedPreferences
  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);

    // Regresar a la pantalla anterior con los datos actualizados
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
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
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
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
