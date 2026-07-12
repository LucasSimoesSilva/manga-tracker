import 'package:flutter/material.dart';

void main() {
  runApp(const MyMangaApp());
}

class MyMangaApp extends StatelessWidget {
  const MyMangaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accentYellow = Color(0xFFFFFE4F);

    return MaterialApp(
      title: 'Manga Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: accentYellow,
        colorScheme: const ColorScheme.dark(
          primary: accentYellow,
          secondary: accentYellow,
          surface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: accentYellow, // Yellow text/icons on the AppBar
          elevation: 1, // Slight shadow below the AppBar
          shadowColor: accentYellow,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14),
          bodySmall: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ---------------------------------------------------------
// MAIN SCREEN
// ---------------------------------------------------------

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Reading',
    'Up to Date',
    'Paused',
    'Completed',
    'Account',
  ];

  final List<Widget> _screens = [
    const ReadingScreen(),
    const UpToDateScreen(),
    const PausedScreen(),
    const CompletedScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Reading'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Up to Date'),
          BottomNavigationBarItem(icon: Icon(Icons.pause), label: 'Paused'),
          BottomNavigationBarItem(icon: Icon(Icons.done_all), label: 'Completed'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

class UpToDateScreen extends StatelessWidget {
  const UpToDateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Mangas waiting for new chapters.'));
  }
}

class PausedScreen extends StatelessWidget {
  const PausedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Paused or Archived mangas.'));
  }
}

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Mangas you have finished reading.'));
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Account settings and Login.'));
  }
}

// ---------------------------------------------------------
// DATA
// ---------------------------------------------------------
class Manga {
  final String id;
  final String title;
  final String coverUrl;
  final String type;
  int currentChapter;

  Manga({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.type,
    required this.currentChapter,
  });
}

// ---------------------------------------------------------
// READING SCREEN
// ---------------------------------------------------------
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