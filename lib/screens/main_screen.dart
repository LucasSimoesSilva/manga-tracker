import 'package:flutter/material.dart';
import 'reading_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Reading',
    'Up to Date',
    'Paused',
    'Completed',
    'Account',
  ];

  final List<Widget> _screens = [
    const ReadingScreen(),
    const UpToDateScreen(),
    const PausedScreen(),
    const CompletedScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _screens[_selectedIndex],
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
          BottomNavigationBarItem(icon: Icon(Icons.pause), label: 'Paused'),
          BottomNavigationBarItem(
            icon: Icon(Icons.done_all),
            label: 'Completed',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

// TEMP SCREENS
class UpToDateScreen extends StatelessWidget {
  const UpToDateScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Mangas waiting for new chapters.'));
}

class PausedScreen extends StatelessWidget {
  const PausedScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Paused or Archived mangas.'));
}

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Mangas you have finished reading.'));
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Account settings and Login.'));
}
