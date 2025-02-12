import 'package:flutter/material.dart';

class PantallaModoOscuro extends StatefulWidget {
  const PantallaModoOscuro({super.key});

  @override
  _PantallaModoOscuroState createState() => _PantallaModoOscuroState();
}

class _PantallaModoOscuroState extends State<PantallaModoOscuro> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo Oscuro'),
      ),
      body: Center(
        child: SwitchListTile(
          title: const Text('Activar Modo Oscuro'),
          value: _isDarkMode,
          onChanged: (bool value) {
            setState(() {
              _isDarkMode = value;
            });
            if (_isDarkMode) {
              // Cambiar a modo oscuro
              // Puedes configurar el tema aquí usando ThemeData
              // En este ejemplo, no se aplica el cambio de tema global
            } else {
              // Cambiar a modo claro
              // También puedes aplicar el tema claro aquí
            }
          },
        ),
      ),
    );
  }
}
