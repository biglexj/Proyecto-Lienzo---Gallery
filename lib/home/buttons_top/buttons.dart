import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // AppBar transparente
        AppBar(
          backgroundColor: Colors.transparent, 
          elevation: 0,
        ),
        // Container personalizado sobre el AppBar
        Container(
          margin: const EdgeInsets.only(top: 45, left: 10, right: 12), // Margen desde la parte superior y los lados
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding interior
          decoration: BoxDecoration(
            color: const Color.fromARGB(241, 99, 168, 65), // Color de fondo del Container
            borderRadius: BorderRadius.circular(50.0), // Bordes redondeados
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search, color: Colors.white), // Icono de búsqueda
              const SizedBox(width: 10.0),
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                onPressed: () {
                  // Acción de la cámara
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (String result) {
                  // Acción del menú
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'ajustes',
                    child: Text('Ajustes'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'acerca_de',
                    child: Text('Acerca de'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20.0);
}
