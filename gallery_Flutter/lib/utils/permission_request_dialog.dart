import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionRequestDialog extends StatelessWidget {
  final VoidCallback onPermissionGranted;

  const PermissionRequestDialog({super.key, required this.onPermissionGranted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Permiso de Almacenamiento',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Esta aplicación necesita acceso a tus archivos para funcionar correctamente.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () async {
            // Verifica los estados de los permisos
            var statusImages = await Permission.photos.status;
            var statusVideos = await Permission.videos.status;
            var statusAudio = await Permission.audio.status;

            // Solicita permisos si son necesarios
            if (statusImages.isDenied || statusVideos.isDenied || statusAudio.isDenied) {
              if (statusImages.isDenied) await Permission.photos.request();
              if (statusVideos.isDenied) await Permission.videos.request();
              if (statusAudio.isDenied) await Permission.audio.request();
            }

            // Verifica si los permisos fueron concedidos
            if (statusImages.isGranted && statusVideos.isGranted && statusAudio.isGranted) {
              onPermissionGranted(); // Llama el callback si los permisos son concedidos
              
              // Asegúrate de que el widget esté montado antes de usar el contexto
              if (context.mounted) {
                Navigator.of(context).pop(); // Cierra el diálogo si todo está bien
              }
            } else {
              // Muestra el mensaje si los permisos no fueron concedidos
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permisos no concedidos.')),
                );
                Navigator.of(context).pop(); // Cierra el diálogo
              }
            }
          },
          child: const Text(
            'Permitir',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 16), // Espacio entre los botones
        ElevatedButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).pop(); // Cierra el diálogo
            }
          },
          child: const Text(
            'Cancelar',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}

Future<bool> showPermissionRequestDialog(BuildContext context) async {
  bool isGranted = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return PermissionRequestDialog(
        onPermissionGranted: () {
          isGranted = true;
        },
      );
    },
  );

  return isGranted;
}
