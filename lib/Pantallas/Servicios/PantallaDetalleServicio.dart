import 'package:flutter/material.dart';

class PantallaDetalleServicio extends StatelessWidget {
  final Map<String, dynamic> servicio;

  const PantallaDetalleServicio({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    final colorPrimario = const Color.fromARGB(255, 46, 5, 82);
    final colorSecundario = const Color.fromARGB(255, 237, 83, 65);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Servicio',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorPrimario, colorSecundario],
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorPrimario, colorSecundario],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.build_circle,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      servicio['taller'] ?? 'Sin taller',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      servicio['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: servicio['estado'] == 'pendiente' 
                            ? Colors.orange 
                            : Colors.green,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        servicio['estado']?.toUpperCase() ?? 'SIN ESTADO',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                    title: 'Detalles del Servicio',
                    icon: Icons.info_outline,
                    content: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.description,
                          label: 'Descripción',
                          value: servicio['descripcion'] ?? 'Sin descripción',
                          colorPrimario: colorPrimario,
                          colorSecundario: colorSecundario,
                        ),
                        _buildDetailRow(
                          icon: Icons.timer,
                          label: 'Duración Estimada',
                          value: '${servicio['duracion']} minutos',
                          colorPrimario: colorPrimario,
                          colorSecundario: colorSecundario,
                        ),
                        _buildDetailRow(
                          icon: Icons.note,
                          label: 'Observaciones',
                          value: servicio['observacion'] ?? 'Sin observaciones',
                          colorPrimario: colorPrimario,
                          colorSecundario: colorSecundario,
                        ),
                      ],
                    ),
                    colorPrimario: colorPrimario,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    title: 'Información de la Pieza',
                    icon: Icons.settings,
                    content: Column(
                      children: [
                        _buildDetailRow(
                          icon: Icons.build,
                          label: 'Nombre de la Pieza',
                          value: servicio['pieza'] ?? 'No especificada',
                          colorPrimario: colorPrimario,
                          colorSecundario: colorSecundario,
                        ),
                        _buildDetailRow(
                          icon: Icons.health_and_safety,
                          label: 'Estado de la Pieza',
                          value: servicio['estado_pieza'] ?? 'No especificado',
                          valueColor: servicio['estado_pieza'] == 'Buena' 
                              ? Colors.green 
                              : Colors.orange,
                          colorPrimario: colorPrimario,
                          colorSecundario: colorSecundario,
                        ),
                      ],
                    ),
                    colorPrimario: colorPrimario,
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
    required Color colorPrimario,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: colorPrimario.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorPrimario.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: colorPrimario,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorPrimario,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(thickness: 1.5),
              ),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required Color colorPrimario,
    required Color colorSecundario,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorSecundario.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorSecundario,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
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