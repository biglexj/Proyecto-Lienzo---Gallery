import 'package:flutter/material.dart';
import 'package:gallery/home/buttons_down/buttons_functions/home_functions.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsByDate =
        getItemsByDate(); // Llama a la función que obtiene las fotos y videos organizados por fecha

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          floating: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Fotos y Videos'),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final date = itemsByDate.keys.elementAt(index);
              final items = itemsByDate[date];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      date, // Muestra la fecha
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: items!.length,
                    itemBuilder: (context, itemIndex) {
                      return Image.network(
                        items[itemIndex], // Muestra la imagen o video
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ],
              );
            },
            childCount: itemsByDate.length,
          ),
        ),
      ],
    );
  }
}
