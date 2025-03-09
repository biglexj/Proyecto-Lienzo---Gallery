import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:mime/mime.dart';
import 'package:file_icon/file_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class Files extends StatefulWidget {
  final String? directory;

  const Files({super.key, this.directory});

  @override
  State<Files> createState() => _FilesState();
}

class _FilesState extends State<Files> {
  final List<Directory> _directoryStack = [];

  @override
  void initState() {
    super.initState();
    if (widget.directory != null) {
      _directoryStack.add(Directory(widget.directory!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.directory == null) {
      return const Center(child: Text('Selecciona una carpeta primero'));
    }

    return _buildFileExplorer();
  }

  Widget _buildFileExplorer() {
    final currentDir = _directoryStack.last;
    final contents = currentDir.listSync();

    return Column(
      children: [
        _buildNavigationBar(),
        Expanded(
          child: ListView.builder(
            itemCount: contents.length,
            itemBuilder: (context, index) => _buildFileItem(contents[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          if (_directoryStack.length > 1)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _navigateBack,
            ),
          Expanded(child: Text(_directoryStack.last.path)),
        ],
      ),
    );
  }

  Widget _buildFileItem(FileSystemEntity entity) {
    final isDirectory = entity is Directory;
    final file = entity is File ? entity : null;
    final mimeType = file != null ? lookupMimeType(entity.path) : null;

    return ListTile(
      leading: isDirectory ? const Icon(Icons.folder, color: Colors.amber) : FileIcon(mimeType ?? '', size: 24),
      title: Text(p.basename(entity.path)),
      subtitle: file != null ? Text('${(file.lengthSync() / 1024).toStringAsFixed(1)} KB') : null,
      trailing: isDirectory ? const Icon(Icons.chevron_right) : null,
      onTap: () => isDirectory ? _navigateToDirectory(entity) : _openFile(entity.path),
    );
  }

  void _navigateBack() {
    if (_directoryStack.length > 1) {
      setState(() => _directoryStack.removeLast());
    }
  }

  void _navigateToDirectory(Directory dir) {
    setState(() => _directoryStack.add(dir));
  }

  Future<void> _openFile(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
