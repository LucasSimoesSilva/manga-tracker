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
        scaffoldBackgroundColor: Colors.black, // Dark background
        primaryColor: accentYellow,
        colorScheme: const ColorScheme.dark(
          primary: accentYellow,
          secondary: accentYellow,
          surface: Colors.black, // Background of cards, dialogs, etc
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: accentYellow, // Yellow text/icons on the AppBar
          elevation: 1, // Slight shadow below the AppBar
          shadowColor: accentYellow,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 16), // Main text
          bodyMedium: TextStyle(color: Colors.white, fontSize: 14), // Standard text
          bodySmall: TextStyle(color: Colors.grey, fontSize: 12), // Less prominent text
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Manga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your Manga Tracker!',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10), // Spacing
            Text(
              'Your reading list will appear here.',
              style: Theme.of(context).textTheme.bodySmall, // Using the grey text
            ),
          ],
        ),
      ),
    );
  }
}