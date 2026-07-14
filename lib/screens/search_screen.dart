import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import 'package:flutter/foundation.dart';

class SearchScreen extends StatefulWidget {
  final Function(Manga) onMangaAdded;

  const SearchScreen({super.key, required this.onMangaAdded});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Manga> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchManga() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    final query = Uri.encodeComponent(_searchController.text);

    String searchPath;
    if (kIsWeb && kReleaseMode) {
      searchPath =
          '/api/manga?title=$query&includes[]=cover_art&order[relevance]=desc';
    } else {
      searchPath =
          'https://api.mangadex.org/manga?title=$query&includes[]=cover_art&order[relevance]=desc';
    }

    final url = Uri.parse(searchPath);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['data'];

        setState(() {
          _searchResults = results
              .map((json) => Manga.fromMangaDexJson(json))
              .toList();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('API Error: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search manga...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white54),
          ),
          style: const TextStyle(color: Colors.white),
          onSubmitted: (_) => _searchManga(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _searchManga),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final manga = _searchResults[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  leading: Image.network(
                    manga.coverUrl,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      color: Colors.grey[800],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                  title: Text(
                    manga.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${manga.type} • ${manga.totalChapters > 0 ? '${manga.totalChapters} chaps' : 'Publishing'}',
                    style: const TextStyle(color: Color(0xFFFFFE4F)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      widget.onMangaAdded(manga);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${manga.title} added!')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
