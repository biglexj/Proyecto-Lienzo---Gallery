import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:exif/exif.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'full_screen_image.dart';

class TimelineView extends StatelessWidget {
  final String? directory;

  const TimelineView({super.key, this.directory});

  @override
  Widget build(BuildContext context) {
    if (directory == null) {
      return const Center(child: Text('Selecciona una carpeta de inicio'));
    }

    return _buildTimelineContent();
  }

  Widget _buildTimelineContent() {
    final dir = Directory(directory!);
    final imageFiles = dir.listSync(recursive: true).where((file) => _isImageFile(file)).cast<File>().toList();

    return FutureBuilder<Map<String, List<File>>>(
      future: _groupImagesByDate(imageFiles),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar las imágenes'));
        }

        final groupedImages = snapshot.data!;
        return CustomScrollView(
          slivers: [
            ...groupedImages.entries.map((entry) {
              return SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDateHeader(entry.key),
                    _buildImageGrid(context, entry.value),
                  ]),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  bool _isImageFile(FileSystemEntity file) {
    if (file is! File) return false;
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
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, List<File> images) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return GestureDetector(
          onTap: () => _openImage(context, image.path),
          child: Image.file(image, fit: BoxFit.cover),
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
