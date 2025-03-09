import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:exif/exif.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import '../../logic/functions/full_screen_image.dart';
import '../../logic/functions/permission_handler.dart';
import '../../logic/functions/timeline_view.dart';

class Home extends StatefulWidget {
  final String? directory;

  const Home({super.key, this.directory});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    if (widget.directory != null) {
      final hasPermission = await PermissionHandler.checkAndRequestPermissions(context);
      setState(() {
        _hasPermission = hasPermission;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.directory == null) {
      return const Center(child: Text('Selecciona una carpeta de inicio'));
    }

    if (!_hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Se requieren permisos para acceder a los archivos'),
            ElevatedButton(
              onPressed: _checkPermissions,
              child: const Text('Solicitar Permisos'),
            ),
          ],
        ),
      );
    }

    return TimelineView(directory: widget.directory);
  }
}
