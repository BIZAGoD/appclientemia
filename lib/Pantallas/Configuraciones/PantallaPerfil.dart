import 'package:appcliente/Pantallas/Configuraciones/PantallaCerrarSesion.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';    //DE AQUI SE OBTIENEN LOS DATOS DE CADA USUARIO

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  _PantallaPerfilState createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  String? userName;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar los datos del usuario desde SharedPreferences
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name');           // Recupera el nombre guardado
      userEmail = prefs.getString('email');         // Recupera el correo guardado
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
        elevation: 4,
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: userName == null || userEmail == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.teal.shade50],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 80,
                      backgroundImage: AssetImage('assets/perfil.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userName ?? 'Nombre no disponible',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userEmail ?? 'Correo no disponible',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print('Editar perfil');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 237, 83, 65),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Editar perfil',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const PantallaCerrarSesion()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Cerrar sesión',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
