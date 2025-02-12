import 'package:appcliente/Pantallas/Servicios/PantallaAgendarServicio.dart';
import 'package:appcliente/Pantallas/Servicios/PantallaAgregarTaller.dart';  // Importar la nueva pantalla
import 'package:flutter/material.dart';

class PantallaDetallesTaller extends StatelessWidget {
  final Taller taller;

  const PantallaDetallesTaller({super.key, required this.taller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),  
        title: const Text(
          'Busqueda de Talleres',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 237, 83, 65),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      taller.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 46, 5, 82),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: Text(taller.direccion),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.green),
                      title: Text(taller.telefono),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: Text(taller.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time, color: Colors.orange),
                      title: Text(taller.horario),
                    ),
                    const Divider(),
                    const Text(
                      '🔧 Servicios que ofrece:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    // Aquí puedes agregar más detalles si es necesario
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),                     //UNA FILA DE BOTONES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                                                        // Navegar a la pantalla de agendar servicio
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaAgendarServicio(taller: taller),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 237, 83, 65),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Agendar una Cita',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${taller.nombre} agregado a favoritos ❤️')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  label: const Text(
                    'Favoritos',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
