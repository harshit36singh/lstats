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
  int refresh = 0;
  List<Map<String, dynamic>> userGroups = [];

  final ScrollController _scrollController = ScrollController();
  Future<void> fetchUserGroups() async {
  try {
    final username = await AuthStorage.getUsername();
    final res = await http.get(
      Uri.parse(
        "https://lstats-railway-backend-production.up.railway.app/groups/my?name=$username",
      ),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        userGroups = List<Map<String, dynamic>>.from(data);
        tabs = ["Global", "College"] + userGroups.map((g) => g['name'] as String).toList();
      });
    } else {
      print("Failed to load groups: ${res.body}");
    }
  } catch (e) {
    print("Error fetching groups: $e");
  }
}
@override
void initState() {
  super.initState();
  fetchUserGroups();
  fetchLeaderboard();
}

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
      await http.get(
        Uri.parse(
          'https://lstats-railway-backend-production.up.railway.app/leaderboard/refresh',
        ),
      );
      await fetchLeaderboard();
      setState(() {
        refresh++;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'LEADERBOARD REFRESHED!',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            backgroundColor: const Color(0xFF00E676),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'FAILED TO REFRESH',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            backgroundColor: const Color(0xFFFF3366),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
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
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            // Compact header matching homepage style - Amber background
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber,
                border: Border.all(color: Colors.black, width: 3),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'LEADERBOARD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(color: Colors.white, offset: Offset(1, 1)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _refreshData,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 36, 234, 248),
                border: Border(
                  bottom: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color:Colors.white,
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
                        final newGroupName = await showModalBottomSheet<String>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: buildgroupsheet(),
                          ),
                        );

                        if (newGroupName != null && newGroupName is String) {
                          setState(() {
                            tabs.add(newGroupName);
                            _selectedIndex = tabs.length - 1;
                          });
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
                        width: 50,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            left: BorderSide(color: Colors.black, width:1.5),
                          ),
                        ),
                        child: const Icon(
                          Iconsax.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _buildTabContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minWidth: 100),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border(
            right: BorderSide(color: Colors.black.withOpacity(0.2), width: 1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Colors.white : Colors.black54,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget buildgroupsheet() {
    final TextEditingController nameofgroup = TextEditingController();
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header - matching homepage cyan color
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFF00D4FF),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.group_add,
                        color: Color(0xFF00D4FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "CREATE GROUP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(color: Colors.black),
                      child: const Text(
                        "GROUP NAME",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        color: const Color(0xFFF8F9FA),
                      ),
                      child: TextField(
                        controller: nameofgroup,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(
                          hintText: "e.g. Coders Squad",
                          hintStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Buttons
                    GestureDetector(
                      onTap: isLoading ? null : () async {
                        final name = nameofgroup.text.trim();
                        if (name.isEmpty) return;
                        setState(() => isLoading = true);

                        try {
                          final ownername = await AuthStorage.getUsername();
                          final uri = Uri.parse(
                            "https://lstats-railway-backend-production.up.railway.app/groups/create?name=$name&username=$ownername",
                          );
                          final res = await http.post(uri);
                          if (res.statusCode == 200) {
                            Navigator.pop(context, name);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed: ${res.body}"),
                                backgroundColor: const Color(0xFFFF3366),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: const Color(0xFFFF3366),
                            ),
                          );
                        } finally {
                          setState(() => isLoading = false);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isLoading ? Colors.grey : Colors.black,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "CREATE GROUP",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            "CANCEL",
                            style: TextStyle(
                              fontSize: 13,
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
    return _buildWrapper(Leaderboard(key: ValueKey(refresh)));
  } else if (_selectedIndex == 1) {
    return _buildWrapper(CollegeLeaderboard(key: ValueKey(refresh)));
  } else {
    final groupIndex = _selectedIndex - 2;
    final group = userGroups[groupIndex];
    return _buildWrapper(
      Groupleaderboard(
        groupid: group['id'],
        groupname: group['name'],
      ),
    );
  }
}


  Widget _buildWrapper(Widget child) {
    return Container(
      key: ValueKey<int>(_selectedIndex),
      width: double.infinity,
      color: const Color(0xFFF8F9FA),
      child: child,
    );
  }
}