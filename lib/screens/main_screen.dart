import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    final nextChapter = manga.currentChapter + 1;
    try {
      await supabase
          .from('mangas')
          .update({'current_chapter': nextChapter})
          .eq('id', manga.id);

      setState(() {
        manga.currentChapter = nextChapter;
      });
    } catch (e) {
      setState(() {
        manga.currentChapter = nextChapter;
      });
    }
  }

  Future<void> _decrementChapter(Manga manga) async {
    if (manga.currentChapter <= 0) return;
    final nextChapter = manga.currentChapter - 1;
    try {
      await supabase
          .from('mangas')
          .update({'current_chapter': nextChapter})
          .eq('id', manga.id);

      setState(() {
        manga.currentChapter = nextChapter;
      });
    } catch (e) {
      setState(() {
        manga.currentChapter = nextChapter;
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

  Future<void> _addMangaToList(Manga manga) async {
    try {
      await supabase.from('mangas').insert({
        'id': manga.id,
        'title': manga.title,
        'cover_url': manga.coverUrl,
        'type': manga.type,
        'status': manga.status,
        'current_chapter': manga.currentChapter,
        'total_chapters': manga.totalChapters,
        'is_completed': false,
        'reading_url': manga.readingUrl,
      });

      setState(() {
        _myAllMangas.add(manga);
      });
    } catch (e) {
      setState(() {
        _myAllMangas.add(manga);
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
        onUpdateUrl: _updateReadingUrl,
        onDelete: _deleteManga,
      ),
      UpToDateScreen(
        mangas: upToDateMangas,
        onComplete: _completeManga,
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

class UpToDateScreen extends StatelessWidget {
  final List<Manga> mangas;
  final Function(Manga) onComplete;
  final Function(Manga, int) onUpdateTotal;
  final Function(Manga, String) onUpdateUrl;
  final Function(Manga) onDelete;

  const UpToDateScreen({
    super.key,
    required this.mangas,
    required this.onComplete,
    required this.onUpdateTotal,
    required this.onUpdateUrl,
    required this.onDelete,
  });

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showEditUrlDialog(BuildContext context, Manga manga) {
    final TextEditingController controller = TextEditingController(
      text: manga.readingUrl ?? '',
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Reading URL for ${manga.title}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Paste your link here',
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
                onUpdateUrl(manga, controller.text);
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

        return Dismissible(
          key: Key(manga.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Manga"),
                  content: Text(
                    "Are you sure you want to delete '${manga.title}'?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) => onDelete(manga),
          child: Card(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _showEditUrlDialog(context, manga),
                                  icon: const Icon(Icons.link),
                                  color: (manga.readingUrl?.isNotEmpty ?? false)
                                      ? const Color(0xFFFFFE4F)
                                      : Colors.grey,
                                  iconSize: 20,
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                                if (manga.readingUrl?.isNotEmpty ?? false) ...[
                                  const SizedBox(width: 12),
                                  IconButton(
                                    onPressed: () =>
                                        _launchUrl(manga.readingUrl!),
                                    icon: const Icon(Icons.open_in_browser),
                                    color: Colors.greenAccent,
                                    iconSize: 20,
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                                const SizedBox(width: 12),
                                IconButton(
                                  onPressed: () => onComplete(manga),
                                  icon: const Icon(Icons.check_circle_outline),
                                  color: Colors.grey,
                                  iconSize: 20,
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ],
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
          ),
        );
      },
    );
  }
}

class CompletedScreen extends StatelessWidget {
  final List<Manga> mangas;
  final Function(Manga) onReopen;
  final Function(Manga) onDelete;

  const CompletedScreen({
    super.key,
    required this.mangas,
    required this.onReopen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (mangas.isEmpty) {
      return const Center(child: Text('You have not completed any manga.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        final manga = mangas[index];

        return Dismissible(
          key: Key(manga.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Delete Manga"),
                  content: Text(
                    "Are you sure you want to delete '${manga.title}'?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Delete"),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) => onDelete(manga),
          child: Card(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            IconButton(
                              onPressed: () => onReopen(manga),
                              icon: const Icon(Icons.settings_backup_restore),
                              color: Colors.grey,
                              iconSize: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                          ],
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
                            Text(
                              'Total Ch. ${manga.totalChapters}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
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
                                  color: Colors.green,
                                  width: 0.5,
                                ),
                              ),
                              child: const Text(
                                'Completed',
                                style: TextStyle(
                                  color: Colors.green,
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
          ),
        );
      },
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Logged in as:', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
