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

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'Api',
    anonKey: 'API_KEY',
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
      ),
      home: const NavigationDrawerWidget(),
    );
  }
}

class NavigationDrawerWidget extends StatefulWidget {
  const NavigationDrawerWidget({super.key});

  @override
  State<NavigationDrawerWidget> createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  String selectedPage = 'Información general';

  final List<DrawerItem> _menuItems = [
    DrawerItem(
      icon: Icons.info_outline,
      title: 'Información general',
      page: 'Información general',
    ),
    DrawerItem(
      icon: Icons.park_outlined,
      title: 'Árbol de la vida',
      page: 'Árbol de la vida',
    ),
    DrawerItem(
      icon: Icons.chat_bubble_outline,
      title: 'Chatbot',
      page: 'Chatbot',
    ),
    DrawerItem(
      icon: Icons.confirmation_number_outlined,
      title: 'Tickets',
      page: 'Tickets',
    ),
    DrawerItem(
      icon: Icons.settings_outlined,
      title: 'Configuración',
      page: 'Configuración',
    ),
  ];

  void _navigateToPage(String page) {
    setState(() {
      selectedPage = page;
    });
  }

  Widget _getPageWidget(String page) {
    switch (page) {
      case 'Información general':
        return InfoGeneralView(onNavigate: _navigateToPage);
      case 'Mapa interactivo':
        return MapaInteractivoView(onNavigate: _navigateToPage);
      case 'Árbol de la vida':
        return ArbolVidaView(onNavigate: _navigateToPage);
      case 'Chatbot':
        return ChatbotView(
          onBack: () => _navigateToPage('Mapa interactivo'),
          onNavigate: _navigateToPage,
        );
      case 'Tickets':
        return TicketsView(onNavigate: _navigateToPage);
      case 'Buscar':
        return SearchView(onNavigate: _navigateToPage);
      case 'Configuración':
        return ConfiguracionView(onNavigate: _navigateToPage);
      default:
        return const Center(child: Text('Seleccione una opción'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Museos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: Colors.green[700],
                size: 20,
              ),
            ),
            tooltip: 'Ir al Chatbot',
            onPressed: () => _navigateToPage('Chatbot'),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search,
                color: Colors.green[700],
                size: 20,
              ),
            ),
            tooltip: 'Buscar',
            onPressed: () => _navigateToPage('Buscar'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            // Header minimalista
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[600]!,
                    Colors.green[800]!,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.museum_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'App Museos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explora y descubre',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Menu items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: _menuItems.length,
                itemBuilder: (context, index) {
                  final item = _menuItems[index];
                  final isSelected = selectedPage == item.page;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateToPage(item.page);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green[50] : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.green[200]! : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected ? Colors.green[700] : Colors.grey[600],
                                size: 22,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? Colors.green[900] : Colors.grey[700],
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.green[700],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Divider(color: Colors.grey[200], height: 1),
                  const SizedBox(height: 16),
                  Text(
                    'Versión 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _getPageWidget(selectedPage),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String page;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.page,
  });
}