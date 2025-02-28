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
  final String? rescate;

  Taller({
    required this.nombre,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.horario,
    required this.logo,
    this.rescate,
  });

  factory Taller.fromJson(Map<String, dynamic> json) {
    return Taller(
      nombre: json['Nombre'],                         // Debe coincidir con la API
      direccion: json['Direccion'],
      telefono: json['Telefono'],
      email: json['Email'],
      horario: json['Horario'],
      logo: json['Logo'],
      rescate: json['Rescate'],
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
  String? tipoFiltrado; // Variable para el tipo de filtrado

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
      talleresFiltrados = talleresDisponibles.where((taller) {
        bool matchesQuery = taller.nombre.toLowerCase().contains(query);
        bool matchesTipoFiltrado = tipoFiltrado == null || 
            (tipoFiltrado == "Rescates" && taller.rescate == "Sí") || 
            (tipoFiltrado == "Todos"); // Mostrar todos si se selecciona "Todos"
        return matchesQuery && matchesTipoFiltrado;
      }).toList();
    });
  }

  void _cambiarTipoFiltrado(String? nuevoTipo) {
    setState(() {
      tipoFiltrado = nuevoTipo;
      _filtrarTalleres(); // Refiltrar después de cambiar el tipo
    });
  }

  void _navegarADetallesTaller(Taller taller, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaDetallesTaller(taller: taller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
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
        title: const Text(
          "Talleres Disponibles",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: tipoFiltrado,
              hint: const Text('Filtrar por', style: TextStyle(fontSize: 16)),
              items: <String>['Todos', 'Rescates'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: _cambiarTipoFiltrado,
              isExpanded: true,
              style: const TextStyle(color: Color(0xFF2E0552)),
              dropdownColor: Colors.white,
            ),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar taller por nombre...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2E0552)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF2E0552)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFFED5341)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                _filtrarTalleres(); // Filtrar al escribir
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: talleresFiltrados.isNotEmpty
                  ? ListView.builder(
                      itemCount: talleresFiltrados.length,
                      itemBuilder: (context, index) {
                        final taller = talleresFiltrados[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _navegarADetallesTaller(taller, context),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2E0552).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: taller.logo.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.network(
                                                  'https://followcar-api-railway-production.up.railway.app/images',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.home_repair_service_rounded,
                                                      size: 30,
                                                      color: Color(0xFF2E0552),
                                                    );
                                                  },
                                                ),
                                              )
                                            : const Icon(
                                                Icons.home_repair_service_rounded,
                                                size: 30,
                                                color: Color(0xFF2E0552),
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              taller.nombre,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2E0552),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 16,
                                                  color: Color(0xFFED5341),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    taller.direccion,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone_outlined,
                                                  size: 16,
                                                  color: Color(0xFFED5341),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  taller.telefono,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 20,
                                        color: Color(0xFF2E0552),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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

