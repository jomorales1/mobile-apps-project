import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ModelView extends StatelessWidget {
  final String modelPath;
  
  const ModelView({
    Key? key,
    required this.modelPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final String urlFinal = modelPath.startsWith('file://') 
      ? modelPath 
      : 'file://$modelPath';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelo 3D'),
        backgroundColor: Colors.green[700],
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

