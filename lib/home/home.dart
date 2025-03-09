import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'screens/home/home_screens.dart';
import 'screens/images/images.dart';
import 'screens/videos/videos.dart';
import 'screens/music/music.dart';
import 'screens/files/files.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final Map<String, String?> _selectedDirectories = {
    'Inicio': Directory.current.path,
    'Fotos': null,
    'Videos': null,
    'Música': null,
    'Archivos': null,
  };

  static const List<String> _directories = <String>[
    'Inicio',
    'Fotos',
    'Videos',
    'Música',
    'Archivos',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildCurrentView() {
    switch (_directories[_selectedIndex]) {
      case 'Inicio':
        return Home(directory: _selectedDirectories['Inicio']);
      case 'Fotos':
        return Images(directory: _selectedDirectories['Fotos']);
      case 'Videos':
        return Videos(directory: _selectedDirectories['Videos']);
      case 'Música':
        return Music(directory: _selectedDirectories['Música']);
      case 'Archivos':
        return Files(directory: _selectedDirectories['Archivos']);
      default:
        return const Center(child: Text('Invalid section'));
    }
  }

  Future<void> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _selectedDirectories[_directories[_selectedIndex]] = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeria'),
        actions: [
          if (_directories[_selectedIndex] != 'Inicio')
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => setState(() {}),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_directories[_selectedIndex] != 'Inicio')
            ElevatedButton(
              onPressed: _pickDirectory,
              child: const Text('Seleccionar carpeta'),
            ),
          Expanded(child: _buildCurrentView()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Fotos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Música',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Archivos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
