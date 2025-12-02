import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelView extends StatelessWidget {
  final String modelPath;
  
  const ModelView({
    super.key,
    required this.modelPath,
  });

  @override
  Widget build(BuildContext context) {

    final String urlFinal = modelPath.startsWith('file://') 
      ? modelPath 
      : 'file://$modelPath';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelo 3D'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: ModelViewer(
        src: urlFinal,
        autoRotate: true,
        cameraControls: true,
        rotationPerSecond: '150deg',
        ar: true,
      ),
    );
  }
}

