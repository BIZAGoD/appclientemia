import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class Rescate {
  final String nombre;
  final String email;
  final String fecha;
  final String problema;
  final String descripcion;
  final String estado;
  final String latitud;
  final String longitud;

  Rescate({
    required this.nombre,
    required this.email,
    required this.fecha,
    required this.problema,
    required this.descripcion,
    required this.estado,
    required this.latitud,
    required this.longitud,
  });

  factory Rescate.fromJson(Map<String, dynamic> json) {
    return Rescate(
      nombre: json['nombre'],
      email: json['email'],
      fecha: json['fecha'],
      problema: json['problema'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      latitud: json['latitud'],
      longitud: json['longitud'],
    );
  }
}

class Taller {
  final String nombre;
  final String latitud;
  final String longitud;
  final String telefono;
  final String email;
  final String horario;
  double? distancia;

  Taller({
    required this.nombre,
    required this.latitud,
    required this.longitud,
    required this.telefono,
    required this.email,
    required this.horario,
    this.distancia,
  });

  factory Taller.fromJson(Map<String, dynamic> json) {
    return Taller(
      nombre: json['Nombre'],
      latitud: json['Latitud'],
      longitud: json['Longitud'],
      telefono: json['Telefono'],
      email: json['Email'],
      horario: json['Horario'],
    );
  }
}

class PantallaDetallesRescate extends StatefulWidget {
  final String userEmail; // Email del usuario actual
  
  const PantallaDetallesRescate({
    super.key,
    required this.userEmail,
  });

  @override
  State<PantallaDetallesRescate> createState() => _PantallaDetallesRescateState();
}

class _PantallaDetallesRescateState extends State<PantallaDetallesRescate> {
  Rescate? rescateActual;
  List<Taller> talleresOrdenados = [];
  bool isLoading = true;
  String? error;
  bool mostrarNotificacion = false;

  // Agregar definición de colores principales
  final Color primaryColor = const Color(0xFF2E0552);
  final Color secondaryColor = const Color(0xFFED5341);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF2E0552);
  final Color lightTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Obtener rescates
      final rescateResponse = await http.get(
        Uri.parse('https://followcar-api-railway-production.up.railway.app/api/rescates')
      );
      
      if (rescateResponse.statusCode != 200) {
        throw Exception('Error al cargar los rescates');
      }

      final rescatesJson = jsonDecode(rescateResponse.body) as List;
      
      // Encontrar el rescate del usuario actual
      final rescateUsuario = rescatesJson.firstWhere(
        (rescate) => rescate['email'] == widget.userEmail,
        orElse: () => null,
      );

      if (rescateUsuario == null) {
        setState(() {
          isLoading = false;
          error = 'No se encontró ningún rescate activo para este usuario';
        });
        return;
      }

      rescateActual = Rescate.fromJson(rescateUsuario);
      
      // Verificar si el estado es "recibido" y mostrar la notificación
      if (rescateActual!.estado.toLowerCase() == 'recibido' && !mostrarNotificacion) {
        setState(() {
          mostrarNotificacion = true;
        });
      }
      
      // Obtener talleres
      final tallerResponse = await http.get(
        Uri.parse('https://followcar-api-railway-production.up.railway.app/api/talleres')
      );
      
      if (tallerResponse.statusCode != 200) {
        throw Exception('Error al cargar los talleres');
      }

      final talleresJson = jsonDecode(tallerResponse.body) as List;
      
      // Convertir y calcular distancias
      talleresOrdenados = talleresJson.map((t) => Taller.fromJson(t)).toList();
      
      // Calcular distancia para cada taller
      for (var taller in talleresOrdenados) {
        taller.distancia = calcularDistancia(
          double.parse(rescateActual!.latitud),
          double.parse(rescateActual!.longitud),
          double.parse(taller.latitud),
          double.parse(taller.longitud),
        );
      }
      
      // Ordenar talleres por distancia
      talleresOrdenados.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Error al cargar los datos: $e';
      });
    }
  }

  double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Radio de la Tierra en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        title: Text(
          'Estatus de Rescate',
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, secondaryColor],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Eliminar Rescate'),
                    content: Text('¿Estás seguro que deseas eliminar esta solicitud de rescate?'),
                    actions: [
                      TextButton(
                        child: Text('Cancelar'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          eliminarRescate();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: secondaryColor,
                        ),
                        child: Text('Eliminar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [secondaryColor.withOpacity(0.1), primaryColor.withOpacity(0.1)],
              ),
            ),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : error != null
                    ? Center(child: Text(error!, style: TextStyle(color: secondaryColor, fontSize: 16)))
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (rescateActual != null) ...[
                              _buildEstadoRescate(),
                              SizedBox(height: 20),
                              _buildDetallesRescate(),
                              SizedBox(height: 30),
                              _buildTitleSection('Talleres cercanos a usted'),
                              SizedBox(height: 10),
                              _buildListaTalleres(),
                            ] else
                              Center(child: Text('No se encontró ningún rescate activo')),
                          ],
                        ),
                      ),
          ),
          if (mostrarNotificacion) _buildNotificacionMecanico(),
        ],
      ),
    );
  }

  Widget _buildTitleSection(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.build_circle, color: primaryColor),
          SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoRescate() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              rescateActual!.estado == 'pendiente' 
                  ? Icons.pending_actions 
                  : Icons.check_circle_outline,
              color: Colors.white,
              size: 35,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Estado actual',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  rescateActual!.estado.toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetallesRescate() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.08),
            spreadRadius: 5,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              color: primaryColor.withOpacity(0.03),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor),
                  SizedBox(width: 10),
            Text(
                    'Detalles de la Solicitud',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            _buildDetalleItem(
              Icons.build_circle_outlined,
              'Problema',
              rescateActual!.problema,
              true,
            ),
            _buildDetalleItem(
              Icons.description_outlined,
              'Descripción',
              rescateActual!.descripcion,
              true,
            ),
            _buildDetalleItem(
              Icons.event_outlined,
              'Fecha',
              rescateActual!.fecha,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetalleItem(IconData icon, String label, String value, bool showDivider) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
            Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: lightTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: primaryColor.withOpacity(0.05)),
      ],
    );
  }

  Widget _buildListaTalleres() {
    // Filtrar talleres dentro de 10km
    final talleresEnRango = talleresOrdenados.where((taller) => 
      (taller.distancia ?? double.infinity) <= 10.0).toList();

    if (talleresEnRango.isEmpty) {
      return Center(
        child: Text(
          'No hay talleres disponibles en un radio de 10 km',
          style: TextStyle(
            color: lightTextColor,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: talleresEnRango.length,
      itemBuilder: (context, index) {
        final taller = talleresEnRango[index];
        return Container(
          margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                color: primaryColor.withOpacity(0.08),
                    spreadRadius: 2,
                blurRadius: 10,
                offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.03),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(Icons.car_repair, color: primaryColor, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                  Text(
                            taller.nombre,
                    style: TextStyle(
                              color: primaryColor,
                      fontWeight: FontWeight.bold,
                              fontSize: 18,
                    ),
                  ),
                  Text(
                            'Distancia: ${taller.distancia?.toStringAsFixed(2)} km',
                    style: TextStyle(
                              color: secondaryColor,
                      fontWeight: FontWeight.w500,
                              fontSize: 14,
                    ),
                  ),
                ],
                    ),
                  ),
                ],
              ),
            ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTallerInfo(Icons.phone_outlined, taller.telefono),
                    SizedBox(height: 8),
                    _buildTallerInfo(Icons.access_time_outlined, taller.horario),
          ],
        ),
      ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTallerInfo(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: primaryColor),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificacionMecanico() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.car_repair,  // Aquí puedes reemplazar con tu gif
                    size: 80,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '¡Un mecánico está en camino!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Llegará en unos minutos',
                style: TextStyle(
                  fontSize: 16,
                  color: lightTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25),
              ElevatedButton(
              onPressed: () {
                  setState(() {
                    mostrarNotificacion = false;
                  });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continuar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Agregar método para eliminar rescate
  Future<void> eliminarRescate() async {
    try {
      final response = await http.delete(
        Uri.parse('https://followcar-api-railway-production.up.railway.app/api/rescates/${widget.userEmail}'),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(); // Regresar a la pantalla anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar el rescate'),
            backgroundColor: secondaryColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión: $e'),
          backgroundColor: secondaryColor,
        ),
      );
    }
  }
}
