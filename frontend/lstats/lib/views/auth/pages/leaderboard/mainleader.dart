import 'package:flutter/material.dart';
import 'package:lstats/views/auth/pages/leaderboard/CollegeLeaderboard.dart';
import 'package:lstats/views/auth/pages/leaderboard/leaderboard.dart';

class MainLeader extends StatefulWidget {
  const MainLeader({super.key});

  @override
  State<MainLeader> createState() => _MainLeaderState();
}

class _MainLeaderState extends State<MainLeader> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2EDF75), // Same base green as Homescreen
      body: SafeArea(
        child: Column(
          children: [
            // ===================== Header =====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      // shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.leaderboard_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Leaderboard",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Global & College Rankings',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // ===================== Tab Switcher =====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  // borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTab("Global", 0)),
                    Expanded(child: _buildTab("College", 1)),
                  ],
                ),
              ),
            ),

            // ===================== Bento Layout Container =====================
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _selectedIndex == 0
                    ? _buildBentoWrapper(const Leaderboard(), Colors.white)
                    : _buildBentoWrapper(const CollegeLeaderboard(), const Color(0xFFFFB84D)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== Tab Button =====================
  Widget _buildTab(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
       
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  // ===================== Wrapper with Bento Style =====================
  Widget _buildBentoWrapper(Widget child, Color color) {
    return Container(
      key: ValueKey<int>(_selectedIndex),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(0), // gapless look
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: child,
      ),
    );
  }
}
