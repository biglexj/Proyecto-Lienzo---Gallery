import 'package:flutter/material.dart';
import 'buttons_down/photo_page.dart';
import 'buttons_down/movie_page.dart';
import 'buttons_down/folder_page.dart';
import 'buttons_down/home_page.dart';
import 'buttons_top/buttons.dart'; // Importa el AppBar personalizado
import '../utils/permission_request_dialog.dart'; // Importa el diálogo de solicitud de permisos

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const PhotosPage(),
    const VideosPage(),
    const FoldersPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Retrasa la solicitud de permisos para evitar problemas durante la construcción
    Future.delayed(Duration.zero, () {
      _requestPermissions();
    });
  }

  void _requestPermissions() async {
    bool granted = await showPermissionRequestDialog(context);

    // Verifica si el widget sigue montado antes de usar `BuildContext`
    if (!mounted) return;

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Se necesitan permisos para acceder a archivos.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(), // Usar el AppBar personalizado
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo,
              color: _selectedIndex == 1
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            label: 'Fotos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.videocam,
              color: _selectedIndex == 2
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.folder,
              color: _selectedIndex == 3
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            label: 'Carpetas',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
