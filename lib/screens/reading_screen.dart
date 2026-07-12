import 'package:flutter/material.dart';
import '../models/manga.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  // (Mock)
  final List<Manga> _myMangas = [
    Manga(
      id: '1',
      title: 'Solo Leveling',
      coverUrl: 'https://cdn.myanimelist.net/images/manga/3/222295.jpg',
      type: 'Manhwa',
      currentChapter: 110,
    ),
    Manga(
      id: '2',
      title: 'Berserk',
      coverUrl: 'https://cdn.myanimelist.net/images/manga/1/157897.jpg',
      type: 'Manga',
      currentChapter: 364,
    ),
  ];

  void _incrementChapter(int index) {
    setState(() {
      _myMangas[index].currentChapter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: _myMangas.length,
      itemBuilder: (context, index) {
        final manga = _myMangas[index];

        return Card(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // MANGA COVER
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  manga.coverUrl,
                  width: 90,
                  height: 130,
                  fit: BoxFit.cover,
                  // If the image does not load
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 130,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // MANGA INFO
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        manga.type.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFFFE4F),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        manga.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      // Controle de Capítulos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ch. ${manga.currentChapter}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _incrementChapter(index),
                            icon: const Icon(Icons.add_circle),
                            color: Theme.of(context).primaryColor,
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}