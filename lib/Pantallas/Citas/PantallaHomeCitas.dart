import 'package:appcliente/Pantallas/Facturas/PantallaHomeFacturas.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaCerrarSesion.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaModoOscuro.dart';
import 'package:appcliente/Pantallas/Configuraciones/PantallaPerfil.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaHomeServicios.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaHomeCitas extends StatefulWidget {
  const PantallaHomeCitas({super.key});

  @override
  State<PantallaHomeCitas> createState() => _PantallaHomeCitasState();
}


class _PantallaHomeCitasState extends State<PantallaHomeCitas> {    
  List<Cita> citas = [];
  bool isLoading = true;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    obtenerUsuarioYCargarCitas();
  }

  Future<void> obtenerUsuarioYCargarCitas() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('email'); // Obtener el email del usuario que inició sesión
    print('Email del usuario obtenido: $userEmail'); // Debugging
    
    if (userEmail != null) {
      await cargarCitas();
    } else {
      print('No se encontró email de usuario'); // Debugging
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> cargarCitas() async {
    try {
      final response = await http.get(Uri.parse(
          'https://followcar-api-railway-production.up.railway.app/api/citasClientes'));
          
      if (response.statusCode == 200) {
        final List<dynamic> citasJson = json.decode(response.body);
        print('Buscando citas para el usuario con email: $userEmail'); // Debugging
        
        setState(() {
          // Filtrar las citas que corresponden al email del usuario actual
          citas = citasJson
              .where((cita) => cita['Email'].toString().toLowerCase() == userEmail?.toLowerCase())
              .map((json) => Cita.fromJson(json))
              .toList();
          isLoading = false;
        });
        
        print('Citas encontradas: ${citas.length}'); // Debugging
      } else {
        print('Error en la respuesta: ${response.statusCode}'); // Debugging
        setState(() {
          citas = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar citas: $e'); // Debugging
      setState(() {
        isLoading = false;
        citas = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Citas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 46, 5, 82),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: citas.isEmpty
                      ? Column(
                          children: [
                            Image.asset(
                              'assets/Imageservicios.png',
                              height: 400,
                              width: 350,
                              fit: BoxFit.contain,
                            ),
                            const Center(
                              child: Text(
                                'Aún no ha programado ninguna cita',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromARGB(255, 155, 150, 158),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: citas.length,
                          itemBuilder: (context, index) {
                            final cita = citas[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () => _mostrarDetallesCita(context, cita),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Color.fromARGB(255, 245, 245, 245),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Color.fromARGB(255, 237, 83, 65),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.calendar_today,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cita.fechaCita,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(255, 46, 5, 82),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${cita.marca} ${cita.modelo}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.directions_car,
                                                color: Color.fromARGB(255, 46, 5, 82),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                cita.placas,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () => _mostrarDetallesCita(context, cita),
                                            child: const Text(
                                              'Detalles',
                                              style: TextStyle(
                                                color: Color.fromARGB(255, 237, 83, 65),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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
    );
  }

  void _mostrarDetallesCita(BuildContext context, Cita cita) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.event,
              color: Color.fromARGB(255, 237, 83, 65),
            ),
            const SizedBox(width: 8),
            const Text('Detalles de la Cita'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detalleItem(Icons.person, 'Nombre', '${cita.nombre} ${cita.apellido}'),
              const SizedBox(height: 12),
              _detalleItem(Icons.phone, 'Teléfono', cita.telefono),
              const SizedBox(height: 12),
              _detalleItem(Icons.email, 'Email', cita.email),
              const SizedBox(height: 12),
              _detalleItem(Icons.directions_car, 'Vehículo', '${cita.marca} ${cita.modelo}'),
              const SizedBox(height: 12),
              _detalleItem(Icons.calendar_today, 'Año', cita.anio),
              const SizedBox(height: 12),
              _detalleItem(Icons.badge, 'Placas', cita.placas),
              const SizedBox(height: 12),
              _detalleItem(Icons.event_available, 'Fecha de Cita', cita.fechaCita),
              const SizedBox(height: 12),
              _detalleItem(Icons.store, 'Taller', cita.taller),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cerrar',
              style: TextStyle(
                color: Color.fromARGB(255, 46, 5, 82),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detalleItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color.fromARGB(255, 46, 5, 82)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Cita {
  final int id;
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final String modelo;
  final String marca;
  final String anio;
  final String placas;
  final String fechaCita;
  final String taller;

  Cita({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.modelo,
    required this.marca,
    required this.anio,
    required this.placas,
    required this.fechaCita,
    required this.taller,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      nombre: json['Nombre'],
      apellido: json['Apellido'],
      telefono: json['Telefono'],
      email: json['Email'],
      modelo: json['Modelo'],
      marca: json['Marca'],
      anio: json['Anio'],
      placas: json['Placas'],
      fechaCita: json['FechaCita'],
      taller: json['Taller'] ?? 'No especificado',
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


