import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const String supabasePubliKey = String.fromEnvironment('SUPABASE_PUBLI_KEY');

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePubliKey);

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
      home: const AuthGate(),
    );
  }
}
