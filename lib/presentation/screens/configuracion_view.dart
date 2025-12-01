import 'package:flutter/material.dart';

class ConfiguracionView extends StatelessWidget {
    final Function(String)? onNavigate;
  const ConfiguracionView({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Configuración'));
  }
}
