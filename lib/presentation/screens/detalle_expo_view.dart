import 'package:flutter/material.dart';

class DetalleExpoView extends StatelessWidget {
  final String nombreExposicion;

  const DetalleExpoView({Key? key, required this.nombreExposicion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreExposicion),
      ),
      body: Center(
        child: Text(
          'Detalle de la exposición: $nombreExposicion',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}