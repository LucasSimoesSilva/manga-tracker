import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

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
          foregroundColor: accentYellow,
          elevation: 1,
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