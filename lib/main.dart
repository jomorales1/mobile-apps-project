
import 'package:app_museos/presentation/screens/search_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/screens/info_general_view.dart';
import 'presentation/screens/mapa_interactivo_view.dart';
import 'presentation/screens/arbol_vida_view.dart';
import 'presentation/screens/chatbot_view.dart';
import 'presentation/screens/tickets_view.dart';
import 'presentation/screens/configuracion_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
    url: 'URL_DE_TU_SUPABASE',
    anonKey: 'TU_ANON_KEY',
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp( debugShowCheckedModeBanner: false, home: NavigationDrawerWidget());
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
        return ChatbotView(
          onBack: () {
            setState(() {
              selectedPage = 'Mapa interactivo';
            });
          },
        );
      case 'Tickets':
        return const TicketsView();
      case 'Buscar':
        return const SearchView();
      case 'Configuración':
        return const ConfiguracionView();
      default:
        return const Center(child: Text('Seleccione una opción'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Museos'),
        actions: [
              IconButton(
              icon: const Icon(Icons.chat),
              tooltip: 'Ir al Chatbot',
              onPressed: () {
                setState(() {
                selectedPage = 'Chatbot';
                });
              },
              ),
              IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Buscar',
              onPressed: () {
                setState(() {
                selectedPage = 'Buscar';
                });
              },
              ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1B5E20)),
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



