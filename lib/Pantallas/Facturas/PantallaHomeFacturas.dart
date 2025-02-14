import 'package:appcliente/Pantallas/Citas/PantallaHomeCitas.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaCerrarSesion.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaModoOscuro.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaPerfil.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaHomeServicios.dart';
import 'package:flutter/material.dart';

class PantallaHomeFacturas extends StatelessWidget {
  const PantallaHomeFacturas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),       //ESTO CAMBIA EL COLOR DEL DRAWER
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      
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
                  Image.asset(                //IMAGEN DE FACTURAS
                    'assets/imageservicios.png',
                    height: 400,
                    width: 350,
                    fit: BoxFit.contain,
                  ),

                  const Center(
                    child: Text(
                      'Aún no ha solicitado ninguna factura',
                      style: TextStyle(
                        fontSize: 23,
                        color: Color.fromARGB(255, 155, 150, 158),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    
       drawer: Drawer(             //AQUI EMPIEZA EL DRAWER
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 9, 152, 177),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                  Text(
                    'Anahi Gonzales',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              iconColor: const Color.fromARGB(255, 46, 5, 82),
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaPerfil()), // Navega a Perfil
                );
              },
            ),
            ListTile(
              iconColor: const Color.fromARGB(255, 46, 5, 82),
              leading: const Icon(Icons.brightness_6),
              title: const Text('Modo Oscuro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaModoOscuro()),       // Navega a Modo Oscuro
                );
              },
            ),
            ListTile(
              iconColor: const Color.fromARGB(255, 46, 5, 82),
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaCerrarSesion()),      // Navega a Cerrar Sesión
                );
              },
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

class AgregarServicioScreen extends StatelessWidget {   //ESTO ES SOLO EJEMPLO QUITARLO DESPUES
  const AgregarServicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Servicio'),
        backgroundColor: const Color.fromARGB(255, 9, 152, 177),
      ),
      body: Center(
        child: const Text(
          'Aquí puedes agregar un nuevo servicio',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
