import 'package:flutter/material.dart';

class PantallaDetallesRescate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estatus de Rescate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Estatus del Rescate:',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            // Aquí puedes agregar más detalles sobre el estatus del rescate
            Text(
              'En Progreso',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            // ... puedes agregar más widgets según sea necesario ...
          ],
        ),
      ),
    );
  }
}
