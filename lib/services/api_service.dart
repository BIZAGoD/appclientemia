import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base de la API
  static const String baseUrl = 'https://followcar-api-railway-production.up.railway.app/api';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Método para obtener todos los usuarios con mejor manejo de errores
  static Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuarios'))
          .timeout(timeoutDuration, onTimeout: () {
        throw Exception('Tiempo de espera agotado al conectar con el servidor');
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        // Devolvemos una lista vacía en lugar de lanzar una excepción
        return [];
      }
    } catch (e) {
      // Devolvemos una lista vacía en caso de error
      return [];
    }
  }

  // Método para registrar un nuevo usuario con mejor manejo de errores
  static Future<Map<String, dynamic>> registrarUsuario(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      ).timeout(timeoutDuration, onTimeout: () {
        throw Exception('Tiempo de espera agotado al conectar con el servidor');
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Error al registrar usuario',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión',
      };
    }
  }
}
