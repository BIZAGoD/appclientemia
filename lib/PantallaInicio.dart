import 'dart:convert';
import 'package:appcliente/PantallaVerificado.dart';
import 'package:appcliente/RecuperacionPassword.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'PantallaRegistro.dart';
import 'package:shared_preferences/shared_preferences.dart';  //ESTO ES DONDE SE GUARDA LOS DATOS DE CADA USUARIO //IMPORTANTE//

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController claveController = TextEditingController();
  String? emailError;
  String? claveError;
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    claveController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      emailError = null;
      claveError = null;
    });

    // Aseguramos un tiempo mínimo de carga para que la animación se vea bien
    final minLoadingDuration = Duration(milliseconds: 2500); // 2.5 segundos
    final loadingStartTime = DateTime.now();

    if (emailController.text.isEmpty || claveController.text.isEmpty) {
      setState(() {
        emailError = emailController.text.isEmpty ? "Ingrese un correo" : null;
        claveError = claveController.text.isEmpty ? "Ingrese una contraseña" : null;
        _isLoading = false;
      });
      return;
    }

    try {
      const String apiUrl = "https://followcar-api-railway-production.up.railway.app/api/usuarios";
      final response = await http.get(Uri.parse(apiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> usuarios = json.decode(response.body);
        
        final usuarioEncontrado = usuarios.firstWhere(
          (usuario) =>
              usuario["Email"].toString().toLowerCase() == emailController.text.toLowerCase() &&
              usuario["Clave"] == claveController.text,
          orElse: () => null,
        );

        if (usuarioEncontrado != null) {
          final prefs = await SharedPreferences.getInstance();
          await Future.wait([
            prefs.setInt('userId', usuarioEncontrado["id"]),
            prefs.setString('nombre', usuarioEncontrado["Nombre"]),
            prefs.setString('apellido', usuarioEncontrado["Apellido"]),
            prefs.setString('email', usuarioEncontrado["Email"]),
            prefs.setString('telefono', usuarioEncontrado["Telefono"]),
            prefs.setString('nombreCompleto', 
              "${usuarioEncontrado["Nombre"]} ${usuarioEncontrado["Apellido"]}")
          ]);

          if (!mounted) return;
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Pantallaverificado()),
          );
        } else {
          setState(() {
            emailError = "Correo o contraseña incorrectos";
            claveError = "Correo o contraseña incorrectos";
          });
        }
      } else {
        _mostrarError("Error al conectar con la API");
      }
    } catch (e) {
      _mostrarError("Ocurrió un error");
      debugPrint('Error en login: $e');
    } finally {
      // Antes de finalizar el loading, aseguramos el tiempo mínimo
      final loadingEndTime = DateTime.now();
      final actualDuration = loadingEndTime.difference(loadingStartTime);
      if (actualDuration < minLoadingDuration) {
        await Future.delayed(minLoadingDuration - actualDuration);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/logohome.webp',
                          height: 125,
                          width: 300,
                          fit: BoxFit.cover, // O prueba BoxFit.fitWidth
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Bienvenido de vuelta!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 183, 17, 17),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 46, 5, 82)),
                          errorText: emailError,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: claveController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 46, 5, 82)),
                          errorText: claveError,
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const Recuperacionpassword()),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: Color.fromARGB(255, 46, 5, 82), fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 183, 17, 17),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Iniciar Sesion",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: const Text(
                          '¿No tienes una cuenta?',
                          style: TextStyle(color: Color.fromARGB(255, 46, 5, 82), fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: ShimmerLoading(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/ZKZg.gif',
                  height: 120,
                  width: 120,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verificando credenciales...',
                  style: TextStyle(
                    color: Color.fromARGB(255, 46, 5, 82),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const LinearProgressIndicator(
                  backgroundColor: Color.fromARGB(255, 183, 17, 17),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 46, 5, 82),
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
