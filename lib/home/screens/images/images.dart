import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import '../../logic/full_screen_image.dart';

class Images extends StatelessWidget {
  final String? directory;

  const Images({super.key, this.directory});

  @override
  Widget build(BuildContext context) {
    if (directory == null) {
      return const Center(child: Text('Selecciona una carpeta primero'));
    }

    return _buildImageGrid(directory!);
  }

  Widget _buildImageGrid(String path) {
    final dir = Directory(path);
    final List<FileSystemEntity> files = dir.listSync().where((file) {
      final mimeType = lookupMimeType(file.path);
      return mimeType?.startsWith('image/') ?? false;
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
          onTap: () => _openImage(context, file.path),
          child: Image.file(File(file.path), fit: BoxFit.cover),
        );
      },
    );
  }

  void _openImage(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imagePath: path),
      ),
    );
  }
}
