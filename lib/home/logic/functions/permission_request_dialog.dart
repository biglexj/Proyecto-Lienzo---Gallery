import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PermissionRequestDialog extends StatelessWidget {
  final VoidCallback onPermissionGranted;

  const PermissionRequestDialog({super.key, required this.onPermissionGranted});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Permiso de Acceso',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Esta aplicación necesita acceso a tus archivos para mostrar y gestionar tu contenido multimedia.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () async {
            try {
              // En Windows, intentamos acceder al directorio de documentos para verificar permisos
              final directory = Directory.current;
              await directory.list().first; // Intenta listar archivos
              
              onPermissionGranted();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo acceder a los archivos. Por favor, asegúrate de que la aplicación tenga los permisos necesarios.'),
                    duration: Duration(seconds: 5),
                  ),
                );
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text(
            'Aceptar',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
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
    barrierDismissible: false,
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
