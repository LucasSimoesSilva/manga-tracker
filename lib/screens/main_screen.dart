import 'package:flutter/material.dart';
import '../models/manga.dart';
import 'reading_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Manga> _myAllMangas = [
    Manga(
      id: '39c71a07-1f0c-4395-9b7d-6dc357d6b38c',
      title: 'Kengan Omega',
      coverUrl: 'https://cdn.myanimelist.net/images/manga/1/216684.jpg',
      type: 'Manga',
      status: 'ongoing',
      currentChapter: 230,
      totalChapters: 232,
    ),
    Manga(
      id: 'b5b21ca1-7d3d-4b92-8015-7798319fbd1d',
      title: 'Shuumatsu no Valkyrie',
      coverUrl:
          'https://cdn.myanimelist.net/images/manga/3/209957.jpg',
      type: 'Manga',
      status: 'ongoing',
      currentChapter: 90,
      totalChapters: 90,
    ),
  ];

  final List<String> _titles = [
    'Reading',
    'Up to Date',
    'Completed',
    'Account',
  ];

  void _incrementChapter(Manga manga) {
    setState(() {
      manga.currentChapter++;
    });
  }

  void _updateTotalChapters(Manga manga, int newTotal) {
    setState(() {
      manga.totalChapters = newTotal;
    });
  }

  void _addMangaToList(Manga manga) {
    setState(() {
      _myAllMangas.add(manga);
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final readingMangas = _myAllMangas
        .where(
          (m) => m.currentChapter < m.totalChapters || m.totalChapters == 0,
        )
        .toList();

    final upToDateMangas = _myAllMangas
        .where(
          (m) => m.totalChapters > 0 && m.currentChapter >= m.totalChapters,
        )
        .toList();

    final List<Widget> screens = [
      ReadingScreen(
        mangas: readingMangas,
        onIncrement: _incrementChapter,
        onUpdateTotal: _updateTotalChapters,
      ),
      UpToDateScreen(
        mangas: upToDateMangas,
        onUpdateTotal: _updateTotalChapters,
      ),
      const CompletedScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Reading',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: 'Up to Date',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Completed',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(onMangaAdded: _addMangaToList),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}

class UpToDateScreen extends StatelessWidget {
  final List<Manga> mangas;
  final Function(Manga, int) onUpdateTotal;

  const UpToDateScreen({
    super.key,
    required this.mangas,
    required this.onUpdateTotal,
  });

  void _showEditTotalDialog(BuildContext context, Manga manga) {
    final TextEditingController controller = TextEditingController(
      text: manga.totalChapters.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Total for ${manga.title}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Latest Available Chapter',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newTotal =
                    int.tryParse(controller.text) ?? manga.totalChapters;
                onUpdateTotal(manga, newTotal);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (mangas.isEmpty) {
      return const Center(
        child: Text('You are not up to date with any manga.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];

        return Card(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 130,
                    color: Colors.grey[800],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 8.0,
                  ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showEditTotalDialog(context, manga),
                            child: Row(
                              children: [
                                Text(
                                  'Ch. ${manga.currentChapter} / ${manga.totalChapters}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFFFE4F),
                                width: 0.5,
                              ),
                            ),
                            child: const Text(
                              'Up to Date',
                              style: TextStyle(
                                color: Color(0xFFFFFE4F),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Mangas you have finished reading.'));
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Account settings and Login (Coming Soon).'));
}
