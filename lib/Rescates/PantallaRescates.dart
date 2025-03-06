import 'package:appcliente/Rescates/PantallaDetallesRescate.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PantallaRescates extends StatefulWidget {
  const PantallaRescates({super.key});

  @override
  _PantallaRescatesState createState() => _PantallaRescatesState();
}

class _PantallaRescatesState extends State<PantallaRescates> {
  final _formKey = GlobalKey<FormState>();
  String _problemaSeleccionado = 'Batería descargada';
  String _descripcion = '';
  bool _solicitudEnviada = false;
  GoogleMapController? _mapController;
  LatLng? _selectedLocation = LatLng(20.886074386383374, -89.74972281045804); // Coordenadas iniciales de YOYOS BURGER
  final Set<Marker> _markers = {};

  final List<String> _problemas = [
    'Batería descargada',
    'Neumático pinchado',
    'Falta de combustible',
    'Falla mecánica',
    'Otro'
  ];

  // Definición de colores principales
  final Color primaryColor = const Color(0xFF2E0552);
  final Color secondaryColor = const Color(0xFFED5341);
  final Color accentColor = const Color(0xFFFFA500);
  final Color backgroundColor = const Color(0xFFF5F5F5);
  final Color textColor = const Color(0xFF2E0552);
  final Color lightTextColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(_selectedLocation!);
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _selectedLocation!,
              zoom: 15,
            ),
          ),
        );
      });
      
      // Obtener la dirección a partir de la ubicación
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      String address = placemarks[0].street ?? 'Dirección no disponible'; // Obtener la dirección
      print("Dirección: $address"); // Imprimir la dirección en la consola

      // Aquí puedes agregar lógica para actualizar la ubicación en tiempo real si es necesario
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: position,
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
        ),
      );
    });
  }

  void _enviarSolicitud() async {
    if (_formKey.currentState!.validate() && _selectedLocation != null) {
      _formKey.currentState!.save();
      setState(() {
        _solicitudEnviada = true;
      });

      // Obtener datos del usuario desde Shared Preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String nombre = prefs.getString('nombre') ?? 'nombre'; // Valor por defecto
      String email = prefs.getString('email') ?? 'usuario@example.com'; // Valor por defecto

      // Crear el objeto de datos a enviar
      final data = {
        'nombre': nombre,
        'email': email,
        'fecha': '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}', // Formato D-M-Y
        'estado': 'pendiente',
        'latitud': _selectedLocation!.latitude.toString(), // Convertir a String
        'longitud': _selectedLocation!.longitude.toString(), // Convertir a String
        'problema': _problemaSeleccionado, // Agregar el tipo de problema
        'descripcion': _descripcion, // Agregar la descripción del problema
      };

    
      final response = await http.post(
        Uri.parse('https://followcar-api-railway-production.up.railway.app/api/rescates'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      // Manejar la respuesta
      if (response.statusCode == 200) {
        print('Solicitud enviada con éxito');
      } else {
        print('Error al enviar la solicitud: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}'); // Imprimir el cuerpo de la respuesta
      }
    } else if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione su ubicación en el mapa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Solicitar un Rescate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor,
                secondaryColor,
              ],
            ),
          ),
        ),
      ),
      body: _solicitudEnviada
          ? _buildSuccessView()
          : _buildFormView(),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [secondaryColor, primaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Solicitud enviada con éxito!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildInfoRow(Icons.build, 'Problema', _problemaSeleccionado),
              const SizedBox(height: 16),
              _buildInfoRow(Icons.description, 'Descripción', _descripcion),
              if (_selectedLocation != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.location_on,
                  'Ubicación',
                  '${_selectedLocation!.latitude.toStringAsFixed(6)},\n${_selectedLocation!.longitude.toStringAsFixed(6)}',
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => PantallaDetallesRescate()),
              ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Detalles de Rescate',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
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

  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [secondaryColor, primaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                icon: Icons.location_on,
                title: 'Su ubicación',
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _selectedLocation == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Obteniendo ubicación...',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _selectedLocation ?? LatLng(0, 0),
                              zoom: 15,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            markers: _markers,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            onTap: (LatLng position) {
                              setState(() {
                                _selectedLocation = position;
                                _updateMarker(position);
                              });
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(
                icon: Icons.build_circle,
                title: 'Detalles del Problema',
                child: Column(
                  children: [
                    DropdownButtonFormField(
                      value: _problemaSeleccionado,
                      items: _problemas.map((String problema) {
                        return DropdownMenuItem(
                          value: problema,
                          child: Text(problema),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _problemaSeleccionado = value.toString();
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: backgroundColor,
                        labelText: 'Tipo de Problema',
                        labelStyle: TextStyle(color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: backgroundColor,
                        labelText: 'Descripción detallada',
                        labelStyle: TextStyle(color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: primaryColor, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingrese una descripción';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _descripcion = value!;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildButton(
                onPressed: _enviarSolicitud,
                text: 'Solicitar Rescate',
                icon: Icons.send,
                color: accentColor,
                elevation: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
    required double elevation,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: elevation,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: lightTextColor,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
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
