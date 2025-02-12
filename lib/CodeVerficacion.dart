import 'dart:async'; // Necesario para usar Timer
import 'package:appcliente/Comprobacion.dart';
import 'package:flutter/material.dart';

class CodeVerificacion extends StatefulWidget {
  const CodeVerificacion({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CodVerificacionState createState() => _CodVerificacionState();
}

class _CodVerificacionState extends State<CodeVerificacion> {
  final TextEditingController _codigoController = TextEditingController();
  int _remainingTime = 30;
  Timer? _timer;
  String? _errorMessage; // Variable para mostrar el mensaje de error

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Iniciar el cronómetro de 30 segundos
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        _timer?.cancel(); // Detener el timer cuando llegue a 0
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  // Detener el cronómetro cuando se salga de la pantalla
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Método para verificar el código
  void _verificarCodigo() {
    if (_remainingTime > 0) {
      // Verificar si el código ingresado es correcto (por ejemplo, '123456')
      if (_codigoController.text == '123456') {
        setState(() {
          _errorMessage = null; // Limpiar el mensaje de error
        });
        // Redirigir a la pantalla de comprobación después de la verificación exitosa
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Comprobacion()),
        );
      } else {
        setState(() {
          _errorMessage = 'Código incorrecto. Intenta nuevamente.';
        });
      }
    }
  }

  // Método para reenviar el código
  void _reenviarCodigo() {
    setState(() {
      _remainingTime = 30; // Reiniciar el cronómetro
      _codigoController.clear(); // Limpiar el campo del código
      _errorMessage = null; // Limpiar el mensaje de error
    });
    _startTimer(); // Iniciar el cronómetro nuevamente
    // Aquí puedes agregar la lógica para reenviar el código al usuario, como hacer una petición a un servidor.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de Código', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 46, 5, 82),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Volver a la pantalla anterior
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ingresa el código de verificación',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 46, 5, 82),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Por favor ingresa el código que te enviamos a tu correo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40),

            // Campo para ingresar el código de verificación
            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Código de Verificación',
                prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 46, 5, 82)),
                labelStyle: const TextStyle(color: Color.fromARGB(255, 46, 5, 82)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82)),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color.fromARGB(255, 46, 5, 82), width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              enabled: _remainingTime > 0, // Deshabilitar el campo cuando el tiempo se acabe
            ),
            const SizedBox(height: 20),

            // Mostrar el cronómetro
            Text(
              'Tiempo restante: $_remainingTime s',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 46, 5, 82),
              ),
            ),

            // Mostrar el mensaje de error si el código es incorrecto
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Botón de "Verificar"
            ElevatedButton(
              onPressed: _remainingTime > 0 ? _verificarCodigo : null, // Deshabilitar si el tiempo ha pasado
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: const Color.fromARGB(255, 237, 83, 65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Verificar'),
            ),

            // Si el código ha expirado, mostramos un mensaje
            if (_remainingTime == 0)
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  'El código ha expirado. Solicita uno nuevo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Botón para reenviar el código
            if (_remainingTime == 0)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: _reenviarCodigo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: const Color.fromARGB(255, 46, 5, 82),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Reenviar Código'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
