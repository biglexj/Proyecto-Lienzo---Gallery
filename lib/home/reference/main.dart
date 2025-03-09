import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:mime/mime.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_icon/file_icon.dart';
import 'package:intl/intl.dart';
import 'package:exif/exif.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galeria',
      theme: ThemeData(
        useMaterial3: true, // Habilitar Material 3
        colorSchemeSeed: Colors.green, // Color base, usado si no hay colores dinámicos disponibles
        brightness: Brightness.light, // Puedes cambiar a dark si prefieres un tema oscuro
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final Map<String, String?> _selectedDirectories = {
    'Inicio': Directory.current.path,
    'Fotos': null,
    'Videos': null,
    'Música': null,
    'Archivos': null,
  };
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Directory> _directoryStack = [];

  static const List<String> _directories = <String>[
    'Inicio',
    'Fotos',
    'Videos',
    'Música',
    'Archivos',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {});
    });
    _directoryStack.add(Directory(_selectedDirectories['Archivos'] ?? Directory.current.path));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      setState(() {
        _selectedDirectories[_directories[_selectedIndex]] = selectedDirectory;
        if (_directories[_selectedIndex] == 'Archivos') {
          _directoryStack.clear();
          _directoryStack.add(Directory(selectedDirectory));
        }
      });
    }
  }

  Widget _buildCurrentView() {
    switch (_directories[_selectedIndex]) {
      case 'Inicio':
        return _buildTimelineView();
      case 'Archivos':
        return _buildFileExplorer();
      default:
        return _buildMediaView();
    }
  }

  Widget _buildMediaView() {
    final currentDirectory = _selectedDirectories[_directories[_selectedIndex]];
    if (currentDirectory == null) {
      return Center(child: Text('Selecciona una carpeta primero'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(currentDirectory, style: TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: _buildDirectoryContent(currentDirectory),
        ),
      ],
    );
  }

  Widget _buildDirectoryContent(String directory) {
    final dir = Directory(directory);
    final List<FileSystemEntity> files = dir.listSync().where((file) {
      return file.path.endsWith('.jpg') || file.path.endsWith('.png') || file.path.endsWith('.mp3') || file.path.endsWith('.wav') || file.path.endsWith('.flac') || file.path.endsWith('.ogg') || file.path.endsWith('.mp4') || file.path.endsWith('.avi') || file.path.endsWith('.mkv') || file.path.endsWith('.webm') || file.path.endsWith('.mov');
    }).toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: files.length,
      itemBuilder: (BuildContext context, int index) {
        final file = files[index];
        final mimeType = lookupMimeType(file.path);

        if (mimeType?.startsWith('image/') ?? false) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(imagePath: file.path),
                ),
              );
            },
            child: Image.file(File(file.path)),
          );
        } else if (mimeType?.startsWith('video/') ?? false) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(videoPath: file.path),
                ),
              );
            },
            child: Icon(Icons.movie, size: 50),
          );
        } else if (mimeType?.startsWith('audio/') ?? false) {
          return GestureDetector(
            onTap: () async {
              await _audioPlayer.play(DeviceFileSource(file.path));
            },
            child: Icon(Icons.music_note, size: 50),
          );
        } else {
          return Icon(Icons.insert_drive_file, size: 50);
        }
      },
    );
  }

  Widget _buildTimelineView() {
    final directory = _selectedDirectories['Inicio'];
    if (directory == null) return Center(child: Text('Selecciona una carpeta de inicio'));

    final dir = Directory(directory);
    final imageFiles = dir
        .listSync(recursive: true)
        .where((file) {
          return file is File && _isImageFile(file);
        })
        .cast<File>()
        .toList();

    return FutureBuilder<Map<String, List<File>>>(
      future: _groupImagesByDate(imageFiles),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error al cargar las imágenes'));
        } else {
          final groupedImages = snapshot.data!;
          return CustomScrollView(
            slivers: [
              ...groupedImages.entries.map((entry) {
                return SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildDateHeader(entry.key),
                      _buildImageGrid(entry.value),
                    ]),
                  ),
                );
              }),
            ],
          );
        }
      },
    );
  }

  bool _isImageFile(File file) {
    final mimeType = lookupMimeType(file.path);
    return mimeType?.startsWith('image/') ?? false;
  }

  Future<Map<String, List<File>>> _groupImagesByDate(List<File> images) async {
    final Map<String, List<File>> grouped = {};

    for (final image in images) {
      final date = await _getImageDate(image);
      grouped.putIfAbsent(date, () => []).add(image);
    }

    return grouped;
  }

  Future<String> _getImageDate(File image) async {
    try {
      final exifData = await readExifFromBytes(image.readAsBytesSync());
      final dateOriginal = exifData['EXIF DateTimeOriginal']?.toString();
      if (dateOriginal != null) {
        final date = DateFormat('yyyy:MM:dd').parse(dateOriginal.split(' ')[0]);
        return DateFormat('dd MMMM yyyy').format(date);
      }
    } catch (_) {}

    final lastModified = image.lastModifiedSync();
    return DateFormat('dd MMMM yyyy').format(lastModified);
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        date,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildFileExplorer() {
    final currentDir = _directoryStack.last;
    final contents = currentDir.listSync();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (_directoryStack.length > 1)
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _navigateBack,
                ),
              Expanded(child: Text(currentDir.path)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: contents.length,
            itemBuilder: (context, index) {
              final entity = contents[index];
              return _buildFileItem(entity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(FileSystemEntity entity) {
    final isDirectory = entity is Directory;
    final file = entity is File ? entity : null;
    final mimeType = file != null ? lookupMimeType(entity.path) : null;

    return ListTile(
      leading: isDirectory
          ? Icon(Icons.folder, color: Colors.amber)
          : FileIcon(
              mimeType ?? '',
              size: 24,
            ),
      title: Text(p.basename(entity.path)),
      subtitle: file != null ? Text('${(file.lengthSync() / 1024).toStringAsFixed(1)} KB') : null,
      trailing: isDirectory ? Icon(Icons.chevron_right) : null,
      onTap: () {
        if (isDirectory) {
          setState(() => _directoryStack.add(entity));
        } else {
          _openFile(entity.path);
        }
      },
    );
  }

  void _navigateBack() {
    if (_directoryStack.length > 1) {
      setState(() => _directoryStack.removeLast());
    }
  }

  Future<void> _openFile(String path) async {
    final mimeType = lookupMimeType(path);

    if (mimeType?.startsWith('image/') ?? false) {
      _openImage(path);
    } else if (mimeType?.startsWith('video/') ?? false) {
      _openVideo(path);
    } else {
      final uri = Uri.file(path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  void _openImage(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imagePath: path),
      ),
    );
  }

  void _openVideo(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: path),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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

  Widget _buildImageGrid(List<File> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullScreenImage(imagePath: image.path),
              ),
            );
          },
          child: Image.file(image, fit: BoxFit.cover),
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const VideoPlayerScreen({super.key, required this.videoPath});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    _videoController.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoController.value.aspectRatio,
        );
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _chewieController?.videoPlayerController.value.isInitialized ?? false ? Chewie(controller: _chewieController!) : CircularProgressIndicator(),
      ),
    );
  }
}
