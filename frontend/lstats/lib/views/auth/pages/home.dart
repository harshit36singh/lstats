import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class Homescreen extends StatefulWidget {
  final String name;

  const Homescreen({super.key, required this.name});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Map<DateTime, int> activity = {};
  int easy = 0, medium = 0, hard = 0;
  Future<void> fetchdetails() async {
    final String name = widget.name;
    final uri = Uri.parse("https://lstats.onrender.com/leetcode/$name");
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
     
        setState(() {
          easy = data['easySolved'] ;
          medium = data['mediumSolved'] ;
          hard = data['hardSolved'];
          Map<String, dynamic> cal = data['calendar'];
          activity = cal.map((k, v) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              int.parse(k) * 1000,
            );
            return MapEntry(date, v as int);
          });
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 62, 62),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFA500),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFA500).withOpacity(0.28),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.name[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Greeting text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right icons
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.sync_outlined,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.show_chart,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 0,
                      bottom: 90, // Extra padding for bottom nav
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF808080),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.local_fire_department_outlined,
                                label: 'Streak',
                                value: "${easy + medium + hard}",

                                bgcolor: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.emoji_events_outlined,
                                label: 'Rank',
                                value: '20',

                                bgcolor: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.code_outlined,
                                label: 'Solved',
                                value: '150',

                                bgcolor: Colors.greenAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.trending_up_outlined,
                                label: 'Progress',
                                value: '85%',

                                bgcolor: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.calendar_today_outlined,
                                label: 'Active Days',
                                value: '45',

                                bgcolor: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.speed_outlined,
                                label: 'Avg Time',
                                value: '12m',

                                bgcolor: Colors.pinkAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Activity",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        HeatMap(
                          datasets: activity,
                          colorMode: ColorMode.opacity,
                          showText: false,
                          size: 20,
                          margin: const EdgeInsets.all(3.5), 
                          textColor: Colors.white,
                          startDate: DateTime.now().subtract(
                            const Duration(days: 180),
                          ),
                          endDate: DateTime.now(),
                          scrollable: true,
                          colorsets: const {
                            1: Colors.green,
                            3: Colors.lightGreen,
                            5: Colors.teal,
                            10: Colors.blue,
                          },
                        ),
                      ],
                    ),
                  ),

                  // Floating Bottom Nav
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CustomBottomNavBar(
                        selectedIndex: 0,
                        onItemTapped: (index) {
                          print("Tapped $index");
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bgcolor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgcolor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgcolor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black, size: 28),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF808080),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onItemTapped(index),
              child: Container(
                height: 55,
                width: 55,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color.fromARGB(255, 0, 0, 0)
                      : const Color.fromARGB(255, 255, 255, 255),
                  border: isSelected
                      ? Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Icon(
                  index == 0
                      ? Icons.home
                      : index == 1
                      ? Icons.qr_code_scanner
                      : index == 2
                      ? Icons.person
                      : Icons.settings,
                  size: 26,
                  color: isSelected
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromARGB(255, 157, 152, 152),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
