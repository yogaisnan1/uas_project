import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'search_tab.dart';
import 'transaction_tab.dart';
import 'profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeTab(),
    SearchTab(),
    TransactionTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF5B5FE9),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/nav_home.png', width: 28, height: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/nav_search.png', width: 28, height: 28),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/nav_history.png', width: 28, height: 28),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/nav_profile.png', width: 28, height: 28),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
