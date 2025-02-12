import 'package:appcliente/Pantallas/Servicios/PantallaDetallesTaller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

                                        // Modelo de Taller
class Taller {
  final String nombre;
  final String direccion;
  final String telefono;
  final String email;
  final String horario;
  final String logo;

  Taller({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.horario,
    required this.logo,
  });

  factory Taller.fromJson(Map<String, dynamic> json) {
    return Taller(
      nombre: json['Nombre'],                         // Debe coincidir con la API
      direccion: json['Direccion'],
      telefono: json['Telefono'],
      email: json['Email'],
      horario: json['Horario'],
      logo: json['Logo'],
    );
  }
}

class Pantallaagregartaller extends StatefulWidget {
  const Pantallaagregartaller({super.key});

  @override
  _PantallaAggTallerState createState() => _PantallaAggTallerState();
}

class _PantallaAggTallerState extends State<Pantallaagregartaller> {
  List<Taller> talleresDisponibles = [];
  List<Taller> talleresFiltrados = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarTalleres();
    searchController.addListener(_filtrarTalleres);
  }

  Future<void> _cargarTalleres() async {
    const String apiUrl =
        'https://followcar-api-railway-production.up.railway.app/api/talleres';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          talleresDisponibles = data.map((t) => Taller.fromJson(t)).toList();
          talleresFiltrados = talleresDisponibles;
        });
      } else {
        print('Error al cargar talleres: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _filtrarTalleres() {
    String query = searchController.text.toLowerCase();
    setState(() {
      talleresFiltrados = talleresDisponibles
          .where((taller) =>
              taller.nombre.toLowerCase().contains(query) ||
              taller.direccion.toLowerCase().contains(query) ||
              taller.telefono.toLowerCase().contains(query))
          .toList();
    });
  }

  void _navegarADetallesTaller(Taller taller, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaDetallesTaller(taller: taller,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( 
        iconTheme: const IconThemeData(color: Colors.white),  
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
        title: const Text(
          "Busqueda de Talleres",
          style: TextStyle(color: Colors.white),   
        ),


      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar taller...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Expanded(
              child: talleresFiltrados.isNotEmpty
                  ? ListView.builder(
                      itemCount: talleresFiltrados.length,
                      itemBuilder: (context, index) {
                        final taller = talleresFiltrados[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: taller.logo.isNotEmpty
                                ? Image.network(
                                    'https://followcar-api-railway-production.up.railway.app/images',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.home_repair_service_rounded, size: 50);
                                    },
                                  )
                                : const Icon(Icons.home_repair_service_rounded, size: 50),
                                iconColor: const Color.fromARGB(255, 46, 5, 82),
                            title: Text(
                              taller.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              
                            ),
                            subtitle: Text(
                              '${taller.direccion} • ${taller.telefono}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios,
                                  color: Color.fromARGB(255, 46, 5, 82)),
                              onPressed: () {
                                _navegarADetallesTaller(taller, context);
                              },
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No hay talleres disponibles.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

                                                                // Pantalla de detalles del taller

