import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import '../../logic/functions/full_screen_image.dart';

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
    final List<File> files = dir
        .listSync()
        .where((file) {
          if (file is! File) return false;
          final mimeType = lookupMimeType(file.path);
          return mimeType?.startsWith('image/') ?? false;
        })
        .map((file) => File(file.path))
        .toList();

    if (files.isEmpty) {
      return const Center(child: Text('No hay imágenes en esta carpeta'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return GestureDetector(
          onTap: () => _openImage(context, file.path, files),
          child: Hero(
            tag: file.path,
            child: Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _openImage(BuildContext context, String path, List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(
          imagePath: path,
          imageList: images.map((file) => file.path).toList(),
          initialIndex: images.indexWhere((file) => file.path == path),
        ),
      ),
    );
  }
}
