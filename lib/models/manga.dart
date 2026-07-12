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