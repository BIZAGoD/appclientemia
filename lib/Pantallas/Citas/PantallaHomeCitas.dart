import 'package:appcliente/Pantallas/Facturas/PantallaHomeFacturas.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaCerrarSesion.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaModoOscuro.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaPerfil.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaHomeServicios.dart';
import 'package:flutter/material.dart';


class PantallaHomeCitas extends StatelessWidget {
  const PantallaHomeCitas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
                    'Citas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 46, 5, 82),
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio entre el texto y la imagen
                  Image.asset(
                    'assets/imageservicios.png',
                    height: 400,
                    width: 350,
                    fit: BoxFit.contain,
                  ),
                  const Center(
                    child: Text(
                      'Aún no ha solicitado ninguna cita',
                      style: TextStyle(
                        wordSpacing: -1,
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


      drawer: Drawer(                                    //AQUI EMPIEZA EL DRAWER
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 237, 83, 65),
              ),
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Image(
            image: AssetImage('assets/perfil.png'),
            width: 80,                                  // Ajusta el tamaño de la imagen si es necesario
            height: 80,                                 // Ajusta el tamaño de la imagen si es necesario
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
              iconColor: Color.fromARGB(255, 46, 5, 82),
              leading: const Icon(Icons.person),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaPerfil()),         // Navega a Perfil
                );
              },
            ),
            ListTile(
              iconColor: Color.fromARGB(255, 46, 5, 82),
              leading: const Icon(Icons.brightness_6),
              title: const Text('Modo Oscuro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaModoOscuro()),          // Navega a Modo oscuro
                );
               
              },
            ),
            ListTile(
              iconColor: Color.fromARGB(255, 144, 2, 2),
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaCerrarSesion()),          // Navega a Cerrar Sesión
               );
              },
            ),
          ],
        ),
      ),



      bottomNavigationBar: BottomNavigationBar(
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
        currentIndex: 1, // Citas está seleccionada
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaHomeservicios()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PantallaHomeFacturas()),
            );
          }
        },
        selectedItemColor: const Color.fromARGB(255, 46, 5, 82),
        unselectedItemColor: const Color.fromARGB(255, 237, 83, 65),
      ),


   ///   floatingActionButton: FloatingActionButton(     //AQUI EMPIEZA LO DEL BOTON DE AGREGAR CITA
      //  onPressed: () {
          // Abrir pantalla de agregar servicio
        //  Navigator.push(
          //  context,
         //   MaterialPageRoute(builder: (context) => const AgregarServicioScreen()),
        //  );
       // },
       // backgroundColor: const Color.fromARGB(255, 46, 5, 82),
      //  child: const Icon(Icons.post_add, color: Colors.white),
     // ),

    );
  }
}

class AgregarServicioScreen extends StatelessWidget {
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


