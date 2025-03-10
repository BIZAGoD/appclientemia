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

      try {
        // Obtener datos del usuario desde Shared Preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String nombre = prefs.getString('name') ?? 'Usuario';
        String email = prefs.getString('email') ?? 'usuario@example.com';

        // Formatear la fecha en el formato correcto DD-MM-YYYY
        DateTime now = DateTime.now();
        String fecha = "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}";

        // Crear el objeto de datos a enviar
        Map<String, dynamic> data = {
          'nombre': nombre,
          'email': email,
          'fecha': fecha,
          'problema': _problemaSeleccionado,
          'descripcion': _descripcion,
          'estado': 'pendiente',
          'latitud': _selectedLocation!.latitude.toString(),
          'longitud': _selectedLocation!.longitude.toString()
        };

        print('Enviando datos: ${jsonEncode(data)}'); // Para depuración

        final response = await http.post(
          Uri.parse('https://followcar-api-railway-production.up.railway.app/api/rescates'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(data),
        );

        print('Código de respuesta: ${response.statusCode}'); // Para depuración
        print('Respuesta: ${response.body}'); // Para depuración

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            _solicitudEnviada = true;
          });
          print('Solicitud enviada con éxito');
        } else {
          throw Exception('Error al enviar la solicitud: ${response.statusCode}');
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _solicitudEnviada = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar la solicitud: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos y asegúrese de seleccionar una ubicación'),
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
            fontWeight: FontWeight.normal,
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
                  decoration: const BoxDecoration(
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
              const SizedBox(height: 16),
              Text(
                '¡Solicitud Enviada!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Un mecanico estara en camino',
                style: TextStyle(
                  fontSize: 16,
                  color: lightTextColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryColor.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    _buildEnhancedInfoRow(
                      Icons.build, 
                      'Problema', 
                      _problemaSeleccionado,
                      primaryColor.withOpacity(0.1),
                      true
                    ),
                    _buildEnhancedInfoRow(
                      Icons.description, 
                      'Descripción', 
                      _descripcion,
                      Colors.transparent,
                      true
                    ),
                    if (_selectedLocation != null)
                      _buildEnhancedInfoRow(
                        Icons.location_on, 
                        'Ubicación', 
                        '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        primaryColor.withOpacity(0.1),
                        false
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // Obtener el email del usuario desde SharedPreferences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String userEmail = prefs.getString('email') ?? '';
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PantallaDetallesRescate(
                        userEmail: userEmail, // Pasar el email del usuario actual
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Detalles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                title: 'Usted esta aqui',
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
                title: 'Problema',
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
                        labelText: 'Indiquenos su problema..',
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
                          return 'Por favor, indiquenos su problema';
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
                icon: Icons.send_rounded,
                color: Color.fromRGBO(237, 83, 65, 1),
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

  Widget _buildEnhancedInfoRow(IconData icon, String label, String value, Color bgColor, bool showDivider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(showDivider ? 0 : 20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: lightTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
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
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: primaryColor.withOpacity(0.05)),
      ],
    );
  }
}
