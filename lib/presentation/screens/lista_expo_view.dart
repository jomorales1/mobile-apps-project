import 'package:app_museos/presentation/screens/detalle_expo_view.dart';
import 'package:flutter/material.dart';

class ListaExpoView extends StatelessWidget {
  const ListaExpoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ejemplo de datos de exposiciones
    final exposiciones = [
      'Expo 1',
      'Expo 2',
      'Expo 3',
      'Expo 4',
      'Expo 5',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Exposiciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: exposiciones.length,
        itemBuilder: (context, index) {
            return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              title: Text(exposiciones[index]),
              leading: const Icon(Icons.event),
              onTap: () {
                Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetalleExpoView(nombreExposicion: exposiciones[index]),
                ),
                );
              },
              ),
            ),
            );
        },
      ),
    );
  }
}