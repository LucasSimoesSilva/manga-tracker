import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/manga.dart';

class ReadingScreen extends StatelessWidget {
  final List<Manga> mangas;
  final Function(Manga) onIncrement;
  final Function(Manga) onDecrement;
  final Function(Manga) onComplete;
  final Function(Manga, int) onUpdateTotal;
  final Function(Manga, int) onUpdateCurrent;
  final Function(Manga, String) onUpdateUrl;
  final Function(Manga) onDelete;

  const ReadingScreen({
    super.key,
    required this.mangas,
    required this.onIncrement,
    required this.onDecrement,
    required this.onComplete,
    required this.onUpdateTotal,
    required this.onUpdateCurrent,
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

  void _showEditChaptersDialog(BuildContext context, Manga manga) {
    final TextEditingController controllerTotalChap = TextEditingController(
      text: manga.totalChapters.toString(),
    );
    final TextEditingController controllerCurrentChap = TextEditingController(
      text: manga.currentChapter.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Chapters for ${manga.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: controllerTotalChap,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Latest Available Chapter',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controllerCurrentChap,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Chapter',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newTotal =
                    int.tryParse(controllerTotalChap.text) ??
                    manga.totalChapters;
                onUpdateTotal(manga, newTotal);

                final newCurrent =
                    int.tryParse(controllerCurrentChap.text) ??
                    manga.currentChapter;
                onUpdateCurrent(manga, newCurrent);

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
      return const Center(child: Text('No mangas in your Reading list.'));
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
                              onTap: () =>
                                  _showEditChaptersDialog(context, manga),
                              child: Row(
                                children: [
                                  Text(
                                    'Ch. ${manga.currentChapter} / ${manga.totalChapters}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => onDecrement(manga),
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: Colors.grey,
                                  iconSize: 28,
                                ),
                                IconButton(
                                  onPressed: () => onIncrement(manga),
                                  icon: const Icon(Icons.add_circle),
                                  color: Theme.of(context).primaryColor,
                                  iconSize: 28,
                                ),
                              ],
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
