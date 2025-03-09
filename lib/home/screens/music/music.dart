import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';

class Music extends StatefulWidget {
  final String? directory;

  const Music({super.key, this.directory});

  @override
  State<Music> createState() => _MusicState();
}

class _MusicState extends State<Music> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.directory == null) {
      return const Center(child: Text('Selecciona una carpeta primero'));
    }

    return _buildMusicList(widget.directory!);
  }

  Widget _buildMusicList(String path) {
    final dir = Directory(path);
    final List<FileSystemEntity> files = dir.listSync().where((file) {
      final mimeType = lookupMimeType(file.path);
      return mimeType?.startsWith('audio/') ?? false;
    }).toList();

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return ListTile(
          leading: const Icon(Icons.music_note),
          title: Text(file.path.split('/').last),
          onTap: () => _playAudio(file.path),
        );
      },
    );
  }

  Future<void> _playAudio(String path) async {
    await _audioPlayer.play(DeviceFileSource(path));
  }
}
