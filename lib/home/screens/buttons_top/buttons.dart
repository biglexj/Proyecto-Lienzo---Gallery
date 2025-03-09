import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function(String)? onSearch;
  final Function()? onCameraPressed;
  final Function(String)? onMenuItemSelected;

  const CustomAppBar({
    super.key,
    this.onSearch,
    this.onCameraPressed,
    this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Container(
          margin: const EdgeInsets.only(top: 45, left: 10, right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(241, 99, 168, 65),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.search, color: Colors.white),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    hintText: 'Buscar',
                    hintStyle: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                onPressed: onCameraPressed,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: onMenuItemSelected,
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
