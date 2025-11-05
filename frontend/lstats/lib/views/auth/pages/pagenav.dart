import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lstats/views/auth/pages/clashpage.dart';
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

  @override
  void initState() {
    super.initState();
    _pages = [
      Homescreen(name: widget.uname),
      const DailyPage(),
      const LeetCodeClash(),
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
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Color(0xFFFFD700), width: 6),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Iconsax.home, 'HOME', 0),
          _buildNavItem(Iconsax.calendar, 'DAILY', 1),
          _buildNavItem(Iconsax.chart_1, 'CLASH', 2),
          _buildNavItem(Iconsax.favorite_chart, 'RANK', 3),
          _buildNavItem(Iconsax.ranking4, 'FRIENDS', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;
    
    // Define colors for each nav item
    Color itemColor;
    switch (index) {
      case 0:
        itemColor = const Color(0xFF0066FF); // Blue
        break;
      case 1:
        itemColor = const Color(0xFF00E676); // Green
        break;
      case 2:
        itemColor = const Color(0xFFFF3366); // Red
        break;
      case 3:
        itemColor = const Color(0xFF6C5CE7); // Purple
        break;
      case 4:
        itemColor = const Color(0xFFFFD700); // Gold
        break;
      default:
        itemColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? itemColor : Colors.transparent,
          border: Border.all(
            color: isActive ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.black : itemColor,
              size: 28,
              shadows: isActive
                  ? [
                      const Shadow(
                        color: Colors.white,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ]
                  : [],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : itemColor,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                shadows: isActive
                    ? [
                        const Shadow(
                          color: Colors.white,
                          offset: Offset(1, 1),
                          blurRadius: 0,
                        ),
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}