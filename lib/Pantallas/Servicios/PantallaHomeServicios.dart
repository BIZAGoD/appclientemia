import 'package:appcliente/Pantallas/Citas/PantallaHomeCitas.dart';
import 'package:appcliente/Pantallas/Facturas/PantallaHomeFacturas.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaCerrarSesion.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaModoOscuro.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaPerfil.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaAgregarTaller.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaDetalleServicio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';


class PantallaHomeservicios extends StatefulWidget {
  const PantallaHomeservicios({super.key});

  @override
  State<PantallaHomeservicios> createState() => _PantallaHomeserviciosState();
}

class _PantallaHomeserviciosState extends State<PantallaHomeservicios> {
  String userName = '';
  String? userImagePath;
  List<dynamic> servicios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
    _cargarServicios();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = '${prefs.getString('name') ?? ''} ${prefs.getString('lastName') ?? ''}';
      userImagePath = prefs.getString('userImagePath');
    });
  }

  Future<void> _cargarServicios() async {
    try {
      final response = await http.get(
        Uri.parse('https://followcar-api-railway-production.up.railway.app/api/serviciosClientes')
      );
      if (response.statusCode == 200) {
        setState(() {
          servicios = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar servicios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),             //ESTO CAMBIA EL COLOR DEL DRAWER 
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
                    'Servicios',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 46, 5, 82),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : servicios.isEmpty 
                      ? Column(
                          children: [
                            Image.asset(
                              'assets/imageservicios.webp',
                              height: 400,
                              width: 350,
                              fit: BoxFit.contain,
                            ),
                            const Center(
                              child: Text(
                                'Sin servicios',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 155, 150, 158),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: servicios.length,
                          itemBuilder: (context, index) {
                            final servicio = servicios[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PantallaDetalleServicio(servicio: servicio),
                                  ),
                                );
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
                                        const Color.fromARGB(255, 237, 83, 65).withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.build_circle,
                                              color: Color.fromARGB(255, 46, 5, 82),
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                servicio['nombre'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color.fromARGB(255, 46, 5, 82),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: servicio['estado'] == 1
                                                    ? Colors.green.withOpacity(0.2)
                                                    : Colors.red.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                servicio['estado'] == 1 ? 'Activo' : 'Inactivo',
                                                style: TextStyle(
                                                  color: servicio['estado'] == 1
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 16),
                                        Text(
                                          'Descripción: ${servicio['descripcion'] ?? ''}',
                                          style: const TextStyle(fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Pieza: ${servicio['pieza'] ?? ''}',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            Text(
                                              '${servicio['duracion']} min',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(255, 237, 83, 65),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ),
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
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      backgroundImage: userImagePath != null 
                          ? FileImage(File(userImagePath!))
                          : const AssetImage('assets/perfil.webp') as ImageProvider,
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


      bottomNavigationBar: BottomNavigationBar(        //AQUI EMPIEZA EL BOTTOM NAVIGATION BAR
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
        currentIndex: 0, // Se mantiene seleccionado "Servicios"
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaHomeCitas()), // Navega a Citas
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaHomeFacturas()), // Navega a Facturas
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 46, 5, 82),
        unselectedItemColor: const Color.fromARGB(255, 237, 83, 65),
      ),
      

      floatingActionButton: FloatingActionButton(          //AQUI EMPIEZA LO DEL BOTON DE AGREGAR TALLER
        onPressed: () {
          // Abrir pantalla de agregar servicio
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Pantallaagregartaller()),
          );
        },
        backgroundColor:  const Color.fromARGB(255, 46, 5, 82),
        child: const Icon(Icons.add_business_rounded, color: Colors.white),
      ),
    );
  }
}





