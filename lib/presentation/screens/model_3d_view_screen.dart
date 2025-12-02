import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Model3DViewScreen extends StatefulWidget {
  final String modelPath;

  const Model3DViewScreen({super.key, required this.modelPath});

  @override
  State<Model3DViewScreen> createState() => _Model3DViewScreenState();
}

class _Model3DViewScreenState extends State<Model3DViewScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Hide the loading indicator after a delay to allow the model to load.
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String modelUrl = Supabase.instance.client.storage
        .from('ModelAPP') // Assuming 'ModelAPP' is the correct bucket
        .getPublicUrl(widget.modelPath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelo 3D'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: [
          ModelViewer(
            src: modelUrl,
            alt: "A 3D model",
            autoRotate: true,
            cameraControls: true,
            rotationPerSecond: '150deg',
            ar: false,
          ),
          if (_isLoading)
            Container(
              color: const Color(0xFF8ba936), // Background color from SplashScreen
              child: Center(
                child: Image.asset('assets/loadgif.gif', width: 100, height: 100),
              ),
            ),
        ],
      ),
    );
  }
}
