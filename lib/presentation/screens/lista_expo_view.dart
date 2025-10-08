import 'package:app_museos/model/exposicion_model.dart';
import 'package:app_museos/presentation/screens/detalle_expo_view.dart';
import 'package:app_museos/repositories/exposicion_repository.dart';
import 'package:flutter/material.dart';

class ListaExpoView extends StatelessWidget {
  const ListaExpoView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MapPoint>>(
      future: ExposicionRepository().fetchExposiciones(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            body: Center(child: Text('No hay exposiciones disponibles.')),
          );
        }

        final loadedPoints = snapshot.data!;
        // Imprimir toda la lista
        print("Exposiciones cargadas:");
        for (var point in loadedPoints) {
          print("ID: ${point.id}, Label: ${point.label}, Posición: (${point.x}, ${point.y}), Imagen: ${point.image}");
        }

   

        return Scaffold(
          appBar: AppBar(
            title: const Text('Lista de Exposiciones'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: ListView.builder(
            itemCount: loadedPoints.length,
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
                  title: Text(loadedPoints[index].label),
                  leading: const Icon(Icons.event),
                  onTap: () {
                    Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetalleExpoView(exposicion_model: loadedPoints[index]),
                    ),
                    );
                  },
                  ),
                ),
                );
            },
          ),
        );
      },
    );
  }
}