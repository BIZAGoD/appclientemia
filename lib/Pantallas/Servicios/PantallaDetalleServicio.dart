import 'package:flutter/material.dart';

class PantallaDetalleServicio extends StatelessWidget {
  final Map<String, dynamic> servicio;

  const PantallaDetalleServicio({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Servicio',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.build_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      servicio['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: servicio['estado'] == 1
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        servicio['estado'] == 1 ? 'ACTIVO' : 'INACTIVO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Información General',
                    icon: Icons.info_outline,
                    content: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.description,
                          label: 'Descripción',
                          value: servicio['descripcion'] ?? 'Sin descripción',
                        ),
                        _buildDetailRow(
                          icon: Icons.timer,
                          label: 'Duración',
                          value: '${servicio['duracion']} minutos',
                        ),
                        _buildDetailRow(
                          icon: Icons.note,
                          label: 'Observación',
                          value: servicio['observacion'] ?? 'Sin observaciones',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Información de la Pieza',
                    icon: Icons.settings,
                    content: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.build,
                          label: 'Pieza',
                          value: servicio['pieza'] ?? 'No especificada',
                        ),
                        _buildDetailRow(
                          icon: Icons.inventory,
                          label: 'Estado de la pieza',
                          value: servicio['estado_pieza'] == 1
                              ? 'Disponible'
                              : 'No disponible',
                          valueColor: servicio['estado_pieza'] == 1
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color.fromARGB(255, 46, 5, 82),
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 5, 82),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color.fromARGB(255, 237, 83, 65),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}