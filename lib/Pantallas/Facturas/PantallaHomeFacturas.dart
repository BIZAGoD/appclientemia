import 'package:appcliente/Pantallas/Citas/PantallaHomeCitas.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaCerrarSesion.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaModoOscuro.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaPerfil.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaHomeServicios.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PantallaHomeFacturas extends StatefulWidget {
  const PantallaHomeFacturas({super.key});

  @override
  State<PantallaHomeFacturas> createState() => _PantallaHomeFacturasState();
}

class _PantallaHomeFacturasState extends State<PantallaHomeFacturas> {
  String userName = '';
  List<dynamic> facturas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarFacturas();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = '${prefs.getString('name') ?? ''} ${prefs.getString('lastName') ?? ''}';
    });
  }

  Future<void> _cargarFacturas() async {
    try {
      final response = await http.get(
        Uri.parse('https://followcar-api-railway-production.up.railway.app/api/servicios'),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          facturas = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (facturas.isEmpty) {
      return Column(
        children: [
          Image.asset(
            'assets/imageservicios.webp',
            height: 400,
            width: 350,
            fit: BoxFit.contain,
          ),
          const Center(
            child: Text(
              'Sin Facturas',
              style: TextStyle(
                fontSize: 23,
                color: Color.fromARGB(255, 155, 150, 158),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: facturas.length,
      itemBuilder: (context, index) {
        final factura = facturas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(factura['Nombre'] ?? 'Sin nombre'),
            subtitle: Text('Precio: \$${factura['Precio']}'),
            trailing: Text('Duración: ${factura['Duracion']} hora(s)'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),       //ESTO CAMBIA EL COLOR DEL DRAWER
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 46, 5, 82),
                Color.fromARGB(255, 237, 83, 65),
              ],
            ),
          ),
        ),
      ),
      
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  const Text(
                    'Facturas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 46, 5, 82),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: _buildContent()),
                ],
              ),
            ),
          ),
        ],
      ),
    
     drawer: Drawer(               //AQUI EMPIEZA EL DRAWER
        child: Column(
          children: [
            Container(
              height: 230,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 46, 5, 82),
                    Color.fromARGB(255, 237, 83, 65),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage('assets/perfil.webp'),
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color.fromARGB(255, 46, 5, 82),
                        ),
                      ),
                      title: const Text(
                        'Perfil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaPerfil()),
                        );
                      },
                    ),
                    const SizedBox(height: 5),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.brightness_6,
                          color: Color.fromARGB(255, 46, 5, 82),
                        ),
                      ),
                      title: const Text(
                        'Modo Oscuro',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaModoOscuro()),
                        );
                      },
                    ),
                    const Divider(
                      height: 40,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 144, 2, 2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: Color.fromARGB(255, 144, 2, 2),
                        ),
                      ),
                      title: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 144, 2, 2),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PantallaCerrarSesion()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(     //AQUI EMPIEZA EL BOTTOM NAVIGATION BAR
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.build_rounded),
            label: 'Servicios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Facturas',
          ),
        ],
        currentIndex: 2, // Se mantiene seleccionado "Facturas"
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaHomeservicios()), // Navega a Servicios
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaHomeCitas()), // Navega a Citas
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 46, 5, 82),
        unselectedItemColor: const Color.fromARGB(255, 237, 83, 65),
      ),


      floatingActionButton: FloatingActionButton(     //AQUI EMPIEZA LO DEL BOTON DE AGREGAR TALLER
        onPressed: () {
          // Abrir pantalla de agregar servicio
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarServicioScreen()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 46, 5, 82),
        child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
      ),
    );
  }
}

