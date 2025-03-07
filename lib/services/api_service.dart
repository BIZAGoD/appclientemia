import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // URL base de la API
  static const String baseUrl = 'https://followcar-api-railway-production.up.railway.app/api';

  // Método para registrar un usuario
  static Future<Map<String, dynamic>> registrarUsuario(Map<String, String> userData) async {
    const String apiUrl = 'https://followcar-api-railway-production.up.railway.app/api/usuarios';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Usuario registrado correctamente'};
      } else {
        return {'success': false, 'message': 'Error al registrar usuario'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final response = await http.get(
      Uri.parse('https://followcar-api-railway-production.up.railway.app/api/usuarios'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }
}
