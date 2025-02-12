import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // URL base de la API
  static const String baseUrl = 'https://followcar-api-railway-production.up.railway.app/api';

  // Método para registrar un usuario
  static Future<Map<String, dynamic>> registrarUsuario(String nombre, String apellido, String telefono, String email, String clave) async {
    final url = Uri.parse('$baseUrl/usuarios/store'); // Endpoint de registro

    try {
      // Realiza la solicitud POST
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // Asegurar formato JSON
        },
        body: json.encode({
          'Nombre': nombre,
          'Apellido': apellido,
          'Telefono': telefono,
          'Email': email,
          'Clave': clave,
        }),
      );


      // Verifica la respuesta
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': json.decode(response.body)['message'] ?? 'Error desconocido',
        };
      }

        
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }
}
