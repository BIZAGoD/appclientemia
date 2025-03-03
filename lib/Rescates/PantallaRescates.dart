import 'package:flutter/material.dart';

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

  final List<String> _problemas = [
    'Batería descargada',
    'Neumático pinchado',
    'Falta de combustible',
    'Falla mecánica',
    'Otro'
  ];

  void _enviarSolicitud() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _solicitudEnviada = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Solicitar un Rescate', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 46, 5, 82),
                Color.fromARGB(255, 237, 83, 65),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 80),
          SizedBox(height: 20),
          Text(
            '¡Solicitud enviada con éxito!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text('Tipo de problema: $_problemaSeleccionado', style: TextStyle(fontSize: 18, color: Colors.white)),
          SizedBox(height: 10),
          Text('Descripción: $_descripcion', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 237, 83, 65), Color.fromARGB(255, 46, 5, 82)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Seleccione el problema:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              DropdownButtonFormField(
                value: _problemaSeleccionado,
                items: _problemas.map((String problema) {
                  return DropdownMenuItem(
                    value: problema,
                    child: Text(problema, style: TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _problemaSeleccionado = value.toString();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                ),
              ),
              SizedBox(height: 20),
              Text('Descripción del problema:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  errorStyle: TextStyle(color: Colors.white),
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
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _enviarSolicitud,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 255, 165, 0),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Solicitar Rescate', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 237, 83, 65),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('Regresar', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
