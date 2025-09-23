import 'package:flutter/material.dart';
import 'presentation/screens/info_general_view.dart';
import 'presentation/screens/mapa_interactivo_view.dart';
import 'presentation/screens/arbol_vida_view.dart';
import 'presentation/screens/chatbot_view.dart';
import 'presentation/screens/tickets_view.dart';
import 'presentation/screens/configuracion_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: NavigationDrawerWidget());
  }
}

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  String selectedPage = 'Información general';

  Widget _getPageWidget(String page) {
    switch (page) {
      case 'Información general':
        return const InfoGeneralView();
      case 'Mapa interactivo':
        return const MapaInteractivoView();
      case 'Árbol de la vida':
        return const ArbolVidaView();
      case 'Chatbot':
        return const ChatbotView();
      case 'Tickets':
        return const TicketsView();
      case 'Configuración':
        return const ConfiguracionView();
      default:
        return const Center(child: Text('Seleccione una opción'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Museos')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'App Museos',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información general'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedPage = 'Información general';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Mapa interactivo'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedPage = 'Mapa interactivo';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.nature),
              title: const Text('Árbol de la vida'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedPage = 'Árbol de la vida';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chatbot'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedPage = 'Chatbot';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.confirmation_num),
              title: const Text('Tickets'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedPage = 'Tickets';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedPage = 'Configuración';
                });
              },
            ),
          ],
        ),
      ),
      body: _getPageWidget(selectedPage),
    );
  }
}
