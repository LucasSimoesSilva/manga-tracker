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

        return ReadingMangaCard(
          manga: manga,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
          onComplete: onComplete,
          onUpdateTotal: onUpdateTotal,
          onUpdateCurrent: onUpdateCurrent,
          onUpdateUrl: onUpdateUrl,
          onDelete: onDelete,
        );
      },
    );
  }
}

class ReadingMangaCard extends StatefulWidget {
  final Manga manga;
  final Function(Manga) onIncrement;
  final Function(Manga) onDecrement;
  final Function(Manga) onComplete;
  final Function(Manga, int) onUpdateTotal;
  final Function(Manga, int) onUpdateCurrent;
  final Function(Manga, String) onUpdateUrl;
  final Function(Manga) onDelete;

  const ReadingMangaCard({
    super.key,
    required this.manga,
    required this.onIncrement,
    required this.onDecrement,
    required this.onComplete,
    required this.onUpdateTotal,
    required this.onUpdateCurrent,
    required this.onUpdateUrl,
    required this.onDelete,
  });

  @override
  State<ReadingMangaCard> createState() => _ReadingMangaCardState();
}

class _ReadingMangaCardState extends State<ReadingMangaCard> {
  Color _cardColor = const Color(0xFF1E1E1E);

  void _triggerFlash() {
    setState(() {
      _cardColor = const Color(0x33fffffe4f);
    });
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _cardColor = const Color(0xFF1E1E1E);
        });
      }
    });
  }

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
                widget.onUpdateUrl(manga, controller.text);
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
      text: (manga.currentChapter + 1).toString(),
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
                  labelText: 'Next Chapter to Read',
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
                widget.onUpdateTotal(manga, newTotal);

                final nextChapterValue =
                    int.tryParse(controllerCurrentChap.text) ??
                    (manga.currentChapter + 1);
                int newCurrent = nextChapterValue - 1;
                if (newCurrent < 0) {
                  newCurrent = 0;
                }
                widget.onUpdateCurrent(manga, newCurrent);

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
    return Dismissible(
      key: Key(widget.manga.id),
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
                "Are you sure you want to delete '${widget.manga.title}'?",
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
      onDismissed: (direction) => widget.onDelete(widget.manga),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                widget.manga.coverUrl,
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
                          widget.manga.type.toUpperCase(),
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
                                  _showEditUrlDialog(context, widget.manga),
                              icon: const Icon(Icons.link),
                              color:
                                  (widget.manga.readingUrl?.isNotEmpty ?? false)
                                  ? const Color(0xFFFFFE4F)
                                  : Colors.grey,
                              iconSize: 20,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                            if (widget.manga.readingUrl?.isNotEmpty ??
                                false) ...[
                              const SizedBox(width: 12),
                              IconButton(
                                onPressed: () =>
                                    _launchUrl(widget.manga.readingUrl!),
                                icon: const Icon(Icons.open_in_browser),
                                color: Colors.greenAccent,
                                iconSize: 20,
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => widget.onComplete(widget.manga),
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
                      widget.manga.title,
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
                              _showEditChaptersDialog(context, widget.manga),
                          child: Row(
                            children: [
                              Text(
                                'Ch. ${widget.manga.currentChapter + 1} / ${widget.manga.totalChapters}',
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
                              onPressed: () => widget.onDecrement(widget.manga),
                              icon: const Icon(Icons.remove_circle_outline),
                              color: Colors.grey,
                              iconSize: 28,
                            ),
                            IconButton(
                              onPressed: () {
                                _triggerFlash();
                                widget.onIncrement(widget.manga);
                              },
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
  }
}
