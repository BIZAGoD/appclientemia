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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 46, 5, 82),
            ),
            const SizedBox(height: 20),
            Text(
              'Cargando facturas...',
              style: TextStyle(
                color: Color.fromARGB(255, 46, 5, 82).withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (facturas.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 46, 5, 82).withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Image.asset(
              'assets/imageservicios.webp',
              height: 300,
              width: 300,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Text(
                  'No hay facturas disponibles',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 46, 5, 82),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Las facturas aparecerán aquí',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 155, 150, 158),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facturas.length,
      itemBuilder: (context, index) {
        final factura = facturas[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Color.fromARGB(255, 46, 5, 82).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                // Aquí puedes agregar la navegación al detalle de la factura
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            factura['Nombre'] ?? 'Sin nombre',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 46, 5, 82),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 46, 5, 82),
                                Color.fromARGB(255, 237, 83, 65),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 46, 5, 82).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '\$${factura['Precio']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 46, 5, 82).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 20,
                            color: Color.fromARGB(255, 237, 83, 65),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duración: ${factura['Duracion']} hora(s)',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 46, 5, 82),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Aquí puedes agregar la funcionalidad para descargar la factura
                          },
                          icon: const Icon(
                            Icons.download_rounded,
                            color: Color.fromARGB(255, 237, 83, 65),
                          ),
                          label: const Text(
                            'Descargar',
                            style: TextStyle(
                              color: Color.fromARGB(255, 237, 83, 65),
                            ),
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

