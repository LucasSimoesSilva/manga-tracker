import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/manga.dart';
import 'reading_screen.dart';
import 'up_to_date_screen.dart';
import 'completed_screen.dart';
import 'account_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Manga> _myAllMangas = [];
  bool _isLoading = true;
  final supabase = Supabase.instance.client;

  final List<String> _titles = [
    'Reading',
    'Up to Date',
    'Completed',
    'Account',
  ];

  @override
  void initState() {
    super.initState();
    _loadMangas();
  }

  Future<void> _loadMangas() async {
    try {
      final response = await supabase
          .from('mangas')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response;

      setState(() {
        _myAllMangas = data
            .map(
              (json) => Manga(
                id: json['id'],
                title: json['title'],
                coverUrl: json['cover_url'],
                type: json['type'],
                status: json['status'],
                isCompleted: json['is_completed'] ?? false,
                currentChapter: json['current_chapter'],
                totalChapters: json['total_chapters'],
                readingUrl: json['reading_url'],
              ),
            )
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _incrementChapter(Manga manga) async {
    if (manga.totalChapters > 0 && manga.currentChapter >= manga.totalChapters)
      return;
    final nextChapter = manga.currentChapter + 1;
    final nowString = DateTime.now().toIso8601String();
    try {
      await supabase
          .from('mangas')
          .update({'current_chapter': nextChapter, 'created_at': nowString})
          .eq('id', manga.id);

      setState(() {
        _myAllMangas.remove(manga);
        manga.currentChapter = nextChapter;
        _myAllMangas.insert(0, manga);
      });
    } catch (e) {
      setState(() {
        _myAllMangas.remove(manga);
        manga.currentChapter = nextChapter;
        _myAllMangas.insert(0, manga);
      });
    }
  }

  Future<void> _decrementChapter(Manga manga) async {
    if (manga.currentChapter <= 0) return;
    final nextChapter = manga.currentChapter - 1;
    final nowString = DateTime.now().toIso8601String();
    try {
      await supabase
          .from('mangas')
          .update({'current_chapter': nextChapter, 'created_at': nowString})
          .eq('id', manga.id);

      setState(() {
        _myAllMangas.remove(manga);
        manga.currentChapter = nextChapter;
        _myAllMangas.insert(0, manga);
      });
    } catch (e) {
      setState(() {
        _myAllMangas.remove(manga);
        manga.currentChapter = nextChapter;
        _myAllMangas.insert(0, manga);
      });
    }
  }

  Future<void> _updateTotalChapters(Manga manga, int newTotal) async {
    try {
      await supabase
          .from('mangas')
          .update({'total_chapters': newTotal})
          .eq('id', manga.id);

      setState(() {
        manga.totalChapters = newTotal;
      });
    } catch (e) {
      setState(() {
        manga.totalChapters = newTotal;
      });
    }
  }

  Future<void> _updateCurrentChapter(Manga manga, int newCurrent) async {
    try {
      await supabase
          .from('mangas')
          .update({'current_chapter': newCurrent})
          .eq('id', manga.id);

      setState(() {
        manga.currentChapter = newCurrent;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating chapter: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateReadingUrl(Manga manga, String newUrl) async {
    try {
      await supabase
          .from('mangas')
          .update({'reading_url': newUrl})
          .eq('id', manga.id);

      setState(() {
        manga.readingUrl = newUrl;
      });
    } catch (e) {
      setState(() {
        manga.readingUrl = newUrl;
      });
    }
  }

  Future<void> _completeManga(Manga manga) async {
    try {
      await supabase
          .from('mangas')
          .update({'is_completed': true})
          .eq('id', manga.id);

      setState(() {
        manga.isCompleted = true;
      });
    } catch (e) {
      setState(() {
        manga.isCompleted = true;
      });
    }
  }

  Future<void> _reopenManga(Manga manga) async {
    try {
      await supabase
          .from('mangas')
          .update({'is_completed': false})
          .eq('id', manga.id);

      setState(() {
        manga.isCompleted = false;
      });
    } catch (e) {
      setState(() {
        manga.isCompleted = false;
      });
    }
  }

  Future<void> _deleteManga(Manga manga) async {
    try {
      await supabase.from('mangas').delete().eq('id', manga.id);

      setState(() {
        _myAllMangas.removeWhere((m) => m.id == manga.id);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting manga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addMangaToList(Manga manga) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('mangas').insert({
        'id': manga.id,
        'title': manga.title,
        'cover_url': manga.rawCoverUrl,
        'type': manga.type,
        'status': manga.status,
        'current_chapter': manga.currentChapter,
        'total_chapters': manga.totalChapters,
        'is_completed': false,
        'reading_url': manga.readingUrl,
        'user_id': userId,
      });

      setState(() {
        _myAllMangas.add(manga);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding manga: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          (m) =>
              m.isCompleted == false &&
              (m.currentChapter < m.totalChapters || m.totalChapters == 0),
        )
        .toList();

    final upToDateMangas = _myAllMangas
        .where(
          (m) =>
              m.isCompleted == false &&
              m.totalChapters > 0 &&
              m.currentChapter >= m.totalChapters,
        )
        .toList();

    final completedMangas = _myAllMangas
        .where((m) => m.isCompleted == true)
        .toList();

    final List<Widget> screens = [
      ReadingScreen(
        mangas: readingMangas,
        onIncrement: _incrementChapter,
        onDecrement: _decrementChapter,
        onComplete: _completeManga,
        onUpdateTotal: _updateTotalChapters,
        onUpdateCurrent: _updateCurrentChapter,
        onUpdateUrl: _updateReadingUrl,
        onDelete: _deleteManga,
      ),
      UpToDateScreen(
        mangas: upToDateMangas,
        onComplete: _completeManga,
        onDecrement: _decrementChapter,
        onUpdateTotal: _updateTotalChapters,
        onUpdateUrl: _updateReadingUrl,
        onDelete: _deleteManga,
      ),
      CompletedScreen(
        mangas: completedMangas,
        onReopen: _reopenManga,
        onDelete: _deleteManga,
      ),
      const AccountScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFFE4F)),
            )
          : screens[_selectedIndex],
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
