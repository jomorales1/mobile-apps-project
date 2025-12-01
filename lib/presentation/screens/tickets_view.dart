import 'package:flutter/material.dart';

class TicketsView extends StatelessWidget {
    final Function(String)? onNavigate;
  const TicketsView({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tickets'));
  }
}
