import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lstats/views/auth/pages/chat.dart';
import 'package:lstats/views/auth/pages/daily.dart';
import 'package:lstats/views/auth/pages/friends.dart';
import 'package:lstats/views/auth/pages/home.dart';
import 'package:lstats/views/auth/pages/leaderboard/mainleader.dart';

class MainNavPage extends StatefulWidget {
  final String uname;
  const MainNavPage({super.key, required this.uname});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  final Color barColor = const Color.fromARGB(255, 229, 120, 89); // orange from your image

  @override
  void initState() {
    super.initState();
    _pages = [
      Homescreen(name: widget.uname),
      const DailyPage(),
     const ChatPage(),
      const MainLeader(),
      const FriendsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      color: barColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Iconsax.home, 0),
          _buildNavItem(Iconsax.calendar, 1),
          _buildNavItem(Iconsax.chart_1, 2),
          _buildNavItem(Iconsax.favorite_chart, 3),
          _buildNavItem(Iconsax.ranking4, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isActive ? 1.3 : 1.0,
          child: Icon(
            icon,
            color: Colors.black,
            size: isActive ? 30 : 25,
          ),
        ),
      ),
    );
  }
}
