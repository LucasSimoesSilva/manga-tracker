import 'package:flutter/foundation.dart';

class Manga {
  final String id;
  final String title;
  final String _coverUrl;
  final String type;
  final String status;
  bool isCompleted;
  int currentChapter;
  int totalChapters;
  String? readingUrl;

  Manga({
    required this.id,
    required this.title,
    required String coverUrl,
    required this.type,
    required this.status,
    required this.isCompleted,
    required this.currentChapter,
    required this.totalChapters,
    this.readingUrl,
  }) : _coverUrl = coverUrl;

  String get rawCoverUrl => _coverUrl;

  String get coverUrl {
    if (kIsWeb && kReleaseMode) {
      if (_coverUrl.startsWith('https://uploads.mangadex.org/covers/')) {
        return _coverUrl.replaceFirst(
          'https://uploads.mangadex.org/covers/',
          '/covers/',
        );
      }
      return _coverUrl;
    }

    if (_coverUrl.startsWith('/covers/')) {
      return _coverUrl.replaceFirst(
        '/covers/',
        'https://uploads.mangadex.org/covers/',
      );
    }

    return _coverUrl;
  }

  factory Manga.fromMangaDexJson(Map<String, dynamic> json) {
    final id = json['id'];
    final attributes = json['attributes'];

    final titleMap = attributes['title'] as Map<String, dynamic>? ?? {};
    final title = titleMap.values.isNotEmpty
        ? titleMap.values.first
        : 'Unknown';

    String coverFileName = '';
    final relationships = json['relationships'] as List? ?? [];
    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        coverFileName = rel['attributes']?['fileName'] ?? '';
        break;
      }
    }

    final coverUrl = coverFileName.isNotEmpty
        ? 'https://uploads.mangadex.org/covers/$id/$coverFileName'
        : 'https://via.placeholder.com/150';

    final lastChapter = attributes['lastChapter'];
    int parsedTotalChapters = 0;
    if (lastChapter != null && lastChapter.toString().isNotEmpty) {
      parsedTotalChapters = int.tryParse(lastChapter.toString()) ?? 0;
    }

    return Manga(
      id: id,
      title: title,
      coverUrl: coverUrl,
      type: attributes['originalLanguage'] == 'ko' ? 'Manhwa' : 'Manga',
      status: attributes['status'] ?? 'unknown',
      isCompleted: false,
      currentChapter: 0,
      totalChapters: parsedTotalChapters,
      readingUrl: null,
    );
  }
}
