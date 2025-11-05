import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/services/api_service.dart';
import 'package:lstats/views/auth/pages/leaderboard/CollegeLeaderboard.dart';
import 'package:lstats/views/auth/pages/leaderboard/groups/create_group_list.dart';
import 'package:lstats/views/auth/pages/leaderboard/leaderboard.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lstats/views/auth/pages/loadingindicator.dart';

class MainLeader extends StatefulWidget {
  const MainLeader({super.key});

  @override
  State<MainLeader> createState() => _MainLeaderState();
}

class _MainLeaderState extends State<MainLeader> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  Future<void> fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://lstats-railway-backend-production.up.railway.app/leaderboard/global',
        ),
      );

      if (response.statusCode == 200) {
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
    }
  }

  Future<void> _refreshData() async {
    try {
      await http.post(
        Uri.parse(
          'https://lstats-railway-backend-production.up.railway.app/leaderboard/refresh',
        ),
      );
      await fetchLeaderboard();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leaderboard refreshed!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error refreshing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to refresh'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> tabs = ["Global", "College"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF2EDF75),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 32,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'LEADERBOARD',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: -1,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _refreshData,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.amberAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: tabs.length,
                          itemBuilder: (context, i) {
                            return _buildTab(tabs[i], i);
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final newGroupName =
                              await showModalBottomSheet<String>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: buildgroupsheet(),
                                ),
                              );

                          if (newGroupName != null && newGroupName is String) {
                            setState(() {
                              tabs.add(newGroupName);
                              _selectedIndex = tabs.length - 1;
                            });
                            // Auto-scroll to the newly added tab
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            );
                          }
                        },
                        child: Container(
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              left: BorderSide(color: Colors.black, width: 1.5),
                            ),
                          ),
                          child: const Icon(Iconsax.add, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          border: Border(
            right: BorderSide(color: Colors.black.withOpacity(0.1), width: 1),
          ),
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

  Widget buildgroupsheet() {
    final TextEditingController nameofgroup = TextEditingController();
    bool isLoading=false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.zero,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.black, width: 6),
              left: BorderSide(color: Colors.black, width: 4),
              right: BorderSide(color: Colors.black, width: 4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D4FF),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.group_add,
                        color: Color(0xFF00D4FF),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "CREATE GROUP",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label with background
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(color: Colors.black),
                      child: const Text(
                        "GROUP NAME",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Text Field
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 3),
                        color: const Color(0xFFF8F9FA),
                      ),
                      child: TextField(
                        controller: nameofgroup,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: const InputDecoration(
                          hintText: "e.g. Coders Squad",
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Create Button
                    GestureDetector(
                      onTap: () async {
                        final name = nameofgroup.text.trim();
                        if (name.isEmpty) return;
                        setState(() {
                          isLoading=true;
                        });

                        try {
                          final ownername = await AuthStorage.getUsername();
                          final uri = Uri.parse(
                            "https://lstats-railway-backend-production.up.railway.app/groups/create?name=$name&username=$ownername"
                          );
                          final res=await http.post(uri);
                          if(res.statusCode==200){
                            Navigator.pop(context,name);
                          }else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text("Failed: ${res.body} (${res.statusCode})"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() => isLoading = false);
                            }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF3366),
                          border: Border(
                            top: BorderSide(color: Colors.black, width: 4),
                            bottom: BorderSide(color: Colors.black, width: 6),
                            left: BorderSide(color: Colors.black, width: 4),
                            right: BorderSide(color: Colors.black, width: 4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "CREATE GROUP",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            "CANCEL",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent() {
    if (_selectedIndex == 0) {
      return _buildBentoWrapper(const Leaderboard(), Colors.white);
    } else if (_selectedIndex == 1) {
      return _buildBentoWrapper(
        const CollegeLeaderboard(),
        const Color(0xFFFFB84D),
      );
    } else {
      String groupname = tabs[_selectedIndex];
      return _buildBentoWrapper(
        Center(
          child: Text(
            "$groupname",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const Color(0xFFB4E7B0),
      );
    }
  }

  Widget _buildBentoWrapper(Widget child, Color color) {
    return Container(
      key: ValueKey<int>(_selectedIndex),
      width: double.infinity,
      color: color,
      child: child,
    );
  }
}
