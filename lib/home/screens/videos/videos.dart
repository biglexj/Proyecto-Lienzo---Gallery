import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import '../../logic/functions/video_player_screen.dart';

class Videos extends StatelessWidget {
  final String? directory;

  const Videos({super.key, this.directory});

  @override
  Widget build(BuildContext context) {
    if (directory == null) {
      return const Center(child: Text('Selecciona una carpeta primero'));
    }

    return _buildVideoGrid(directory!);
  }

  Widget _buildVideoGrid(String path) {
    final dir = Directory(path);
    final List<FileSystemEntity> files = dir.listSync().where((file) {
      final mimeType = lookupMimeType(file.path);
      return mimeType?.startsWith('video/') ?? false;
    }).toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return GestureDetector(
          onTap: () => _openVideo(context, file.path),
          child: const Icon(Icons.movie, size: 50),
        );
      },
    );
  }

  void _openVideo(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoPath: path),
      ),
    );
  }
}
