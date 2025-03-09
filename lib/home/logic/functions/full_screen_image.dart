import 'package:flutter/material.dart';
import 'dart:io';

class FullScreenImage extends StatefulWidget {
  final String imagePath;
  final List<String> imageList;
  final int initialIndex;

  const FullScreenImage({
    super.key, 
    required this.imagePath,
    required this.imageList,
    required this.initialIndex,
  });

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late int currentIndex;
  
  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _nextImage() {
    setState(() {
      if (currentIndex < widget.imageList.length - 1) {
        currentIndex++;
      }
    });
  }

  void _previousImage() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1}/${widget.imageList.length}'),
      ),
      body: Stack(
        children: [
          // Imagen central
          Center(
            child: Image.file(File(widget.imageList[currentIndex])),
          ),
          // Botón izquierdo
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, size: 40),
              onPressed: currentIndex > 0 ? _previousImage : null,
              color: Colors.white,
            ),
          ),
          // Botón derecho
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, size: 40),
              onPressed: currentIndex < widget.imageList.length - 1 ? _nextImage : null,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
