import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lstats/views/auth/pages/daily.dart';
import 'package:lstats/views/auth/pages/friends.dart';
import 'package:lstats/views/auth/pages/home.dart';
import 'package:lstats/views/auth/pages/leaderboard/leaderboard.dart';
import 'package:lstats/views/auth/pages/leaderboard/mainleader.dart';



class MainNavPage extends StatefulWidget {
  final String uname;
  const MainNavPage({super.key,required this.uname});

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
      const MainLeader(),
      const FriendsPage(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         print("fuck off");
        },
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
        child: const Icon(Iconsax.add5, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.white,
          elevation: 0,
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Iconsax.home, 'Home', 0),
                _buildNavItem(Iconsax.calendar, 'Daily', 1),
                const SizedBox(width: 50), // gap for FAB
                _buildNavItem(Iconsax.ranking4, 'Rank', 2),
                _buildNavItem(Iconsax.favorite_chart, 'Friends', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Individual navigation button
  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF9CA3AF),
              size: 25,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF9CA3AF),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
