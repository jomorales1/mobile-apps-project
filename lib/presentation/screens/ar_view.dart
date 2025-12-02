import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ARViewScreen extends StatefulWidget {
  final String modelPath;

  const ARViewScreen({super.key, required this.modelPath});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Hide the loading indicator after a delay to allow the model to load.
    // This is a simple approach. A more robust solution might involve
    // communication from the webview, which is not directly supported by model_viewer_plus.
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
    final String modelUrl = widget.modelPath.startsWith('http')
        ? widget.modelPath
        : Supabase.instance.client.storage
            .from('ModelAPP')
            .getPublicUrl(widget.modelPath);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modelo 3D AR'),
      ),
      body: Stack(
        children: [
          ModelViewer(
            src: modelUrl,
            alt: "A 3D model",
            ar: true,
            autoRotate: true,
            cameraControls: true,
            rotationPerSecond: '150deg',
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
