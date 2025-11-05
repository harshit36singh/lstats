import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:lstats/services/api_service.dart';
import 'package:lstats/views/auth/login_page.dart';
import 'package:lstats/views/auth/pages/Settings.dart';
import 'package:lstats/views/auth/pages/loadingindicator.dart';
import 'package:home_widget/home_widget.dart';

class Homescreen extends StatefulWidget {
  final String name;

  const Homescreen({super.key, required this.name});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Timer? loadingtimer;
  final random = Random();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<DateTime, int> activity = {};
  int easy = 0, medium = 0, hard = 0;
  int globalrank = 0;
  int activedays = 0;
  String res = '';
  int reputation = 0;
  bool isLoading = true;
  List<Map<String, String>> rawbadges = [];
  List<Map<String, String>> badges = [];
  int solvePercentage = 0;
  int streak = 0;

  int te = 0, tm = 0, th = 0;

  Future<void> updateStreakWidget() async {
    int streakValue = calculateStreak();
    await HomeWidget.saveWidgetData<int>('streak', streakValue);
    await HomeWidget.updateWidget(
      name: 'YourWidgetProvider',
      iOSName: 'YourWidgetProvider',
    );
  }
void _showNotificationDropdown(BuildContext context, List notifications) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
  final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
  
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.3), // Semi-transparent backdrop
    builder: (context) => Stack(
      children: [
        // Invisible barrier to close on tap outside
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.transparent),
        ),
        // Notification dropdown - positioned right below the bell
        Positioned(
          top: buttonPosition.dy + button.size.height -40, // 8px gap below button
          right: MediaQuery.of(context).size.width - (buttonPosition.dx + button.size.width), // Align right edge with button
          child: Material(
            elevation: 12,
            shadowColor: Colors.black.withOpacity(0.5),
            color: Colors.transparent,
            child: Container(
              width: 360,
              constraints: const BoxConstraints(maxHeight: 450),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Colors.black),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'NOTIFICATIONS',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification list
                  Flexible(
                    child: notifications.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_off,
                                    size: 40,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No new notifications',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final no = notifications[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFF3366),
                                            ),
                                            child: const Icon(
                                              Icons.person_add,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              no['message'] ?? "",
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        border: Border(
                                          top: BorderSide(color: Colors.black, width: 2),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              final id = no['id'];
                                              if (id != null) {
                                                final uri = Uri.parse(
                                                  "https://lstats-railway-backend-production.up.railway.app/notification/$id/read",
                                                );
                                                try {
                                                  final r = await http.post(uri);
                                                  if (r.statusCode == 200) {
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                          'MARKED AS READ',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w900,
                                                            letterSpacing: 1,
                                                          ),
                                                        ),
                                                        backgroundColor: const Color(0xFF00E676),
                                                        behavior: SnackBarBehavior.floating,
                                                        duration: const Duration(seconds: 1),
                                                        shape: RoundedRectangleBorder(
                                                          side: const BorderSide(
                                                            color: Colors.black,
                                                            width: 3,
                                                          ),
                                                          borderRadius: BorderRadius.zero,
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  print('Error marking as read: $e');
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00E676),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.done_all,
                                                    color: Colors.black,
                                                    size: 14,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    'MARK READ',
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ],
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
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  int calculateStreak() {
    if (activity.isEmpty) return 0;
    final sorteddate = activity.keys.toList()..sort((a, b) => b.compareTo(a));
    int streak = 0;
    DateTime currentday = DateTime.now();
    currentday = DateTime(currentday.year, currentday.month, currentday.day);
    for (var date in sorteddate) {
      final normaldate = DateTime(date.year, date.month, date.day);
      if (normaldate == currentday && (activity[date] ?? 0) > 0) {
        streak++;
        currentday = currentday.subtract(const Duration(days: 1));
      } else if (normaldate.isBefore(currentday)) {
        break;
      }
    }

    return streak;
  }

  Future<void> fetchdetails() async {
    final String name = widget.name;
    final uri = Uri.parse("https://lstats.onrender.com/leetcode/$name");

    try {
      final response = await http.get(uri);
      print("Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Full response: $data");

        final calendarRaw = data['calendar'];
        Map<DateTime, int> parsedData = {};

        if (calendarRaw != null && calendarRaw.isNotEmpty) {
          final Map<String, dynamic> cal = json.decode(calendarRaw);
          cal.forEach((key, value) {
            final date = DateTime.fromMillisecondsSinceEpoch(
              int.parse(key) * 1000,
            );
            final normalizedDate = DateTime(date.year, date.month, date.day);
            int v = value as int;
            if (v >= 10) {
              v = 10;
            } else if (v >= 5) {
              v = 5;
            } else if (v >= 3) {
              v = 3;
            } else if (v >= 1) {
              v = 1;
            } else {
              v = 0;
            }
            parsedData[normalizedDate] = v;
          });
        }

        setState(() {
          easy = data['easySolved'] ?? 0;
          medium = data['mediumSolved'] ?? 0;
          hard = data['hardSolved'] ?? 0;
          activity = parsedData;
          globalrank = data['ranking'];
          activedays = data['activeDays'];
          te = data['easyTotal'];
          tm = data['mediumTotal'];
          th = data['hardTotal'];
          res = data['profilePic'];
          reputation = data['reputation'];
          streak = calculateStreak();
          updateStreakWidget();

          isLoading = false;
          loadingtimer?.cancel();
          List<Map<String, dynamic>> tempBadges =
              List<Map<String, dynamic>>.from(data['badges']);

          badges = tempBadges.map((badge) {
            return {
              'icon': badge['icon'] as String,
              'displayName': badge['displayName'] as String,
            };
          }).toList();
        });
      } else {
        print("Error: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching details: $e");
    }
  }

  Future<void> _handleSignOut() async {
    await AuthStorage.logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "SIGNED OUT SUCCESSFULLY!",
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
      await Future.delayed(const Duration(seconds: 1));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3366),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black),
                      child: const Icon(
                        Icons.warning,
                        color: Color(0xFFFF3366),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SIGN OUT?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Are you sure you want to sign out?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              _handleSignOut();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                  bottom: BorderSide(
                                    color: Colors.black,
                                    width: 5,
                                  ),
                                  left: BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                  right: BorderSide(
                                    color: Colors.black,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'SIGN OUT',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchdetails();
  }

  @override
  Widget build(BuildContext context) {
    final totalSolved = easy + medium + hard;
    final totalProblems = te + tm + th;
    solvePercentage = totalProblems > 0
        ? ((totalSolved / totalProblems) * 100).round()
        : 0;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF8F9FA),
        drawer: _buildBrutalDrawer(),
        drawerEnableOpenDragGesture: true,
        body: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (details.delta.dx > 0) {
              _scaffoldKey.currentState?.openDrawer();
            }
          },
          child: isLoading
              ? BrutalistLoadingIndicator()
              : SafeArea(
                  child: Column(
                    children: [
                      _buildMaximalistHeader(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            children: [
                              _buildHeroSection(),
                              _buildStatsRow(),
                              _buildDifficultySection(),
                              _buildActivitySection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBrutalDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF2EDF75),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3366),
              border: Border(bottom: BorderSide(color: Colors.black, width: 6)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // User Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipRect(
                    child: Image.network(
                      res,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 60,
                          color: Color(0xFFFF3366),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Username
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Text(
                    widget.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'PROFILE',
                    color: const Color(0xFF00D4FF),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.emoji_events,
                    title: 'MY STATS',
                    color: const Color(0xFFFFB84D),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to stats
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.military_tech,
                    title: 'MY BADGES',
                    color: const Color(0xFFFFD700),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to badges
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.trending_up,
                    title: 'PROGRESS',
                    color: const Color(0xFFB4E7B0),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to progress
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'SETTINGS',
                    color: const Color(0xFFE0B0FF),
                    onTap: () async {
                      Navigator.pop(context);
                      final userId = await AuthStorage.getuserid();
                      if (userId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(userId: userId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('User ID not found')),
                        );
                      }
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'HELP & FAQ',
                    color: const Color(0xFFFFE66D),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black, width: 6)),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showSignOutDialog();
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SIGN OUT',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFFFF3366),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaximalistHeader() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        color: Colors.amber,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Menu Button
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.menu, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(color: Colors.black),
                    child: const Text(
                      'LEETCODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'DASHBOARD',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        letterSpacing: -2,
                        shadows: [
                          Shadow(color: Colors.white, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
         Builder(
           builder: (context) {
             return GestureDetector(
               onTap: () async {
                 final username = await AuthStorage.getUsername();
                 final uri = Uri.parse(
                   "https://lstats-railway-backend-production.up.railway.app/notification/unread?username=$username",
                 );
                 try {
                   final res = await http.get(uri);
                   if (res.statusCode == 200) {
                     final List d = jsonDecode(res.body);
                     _showNotificationDropdown(context, d);
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to fetch notifications'),
              ),
                     );
                   }
                 } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text('Error: $e')),
                   );
                 }
               },
               child: Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.black,
                   border: Border.all(color: Colors.white, width: 2),
                 ),
                 child: const Icon(
                   Icons.notifications,
                   color: Colors.white,
                   size: 32,
                 ),
               ),
             );
           }
         ),
          ],
        ),
      ),
    );
  }
Widget _buildnotificationsheet(List n) {
  if (n.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Text(
          'No new notifications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
  
  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: n.length,
    itemBuilder: (context, index) {
      final no = n[index];
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notification_important,
              color: Colors.black,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                no['message'] ?? "",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final id = no['id'];
                if (id != null) {
                  final uri = Uri.parse(
                    "https://lstats-railway-backend-production.up.railway.app/notification/$id/read",
                  );
                  try {
                    final r = await http.post(uri);
                    if (r.statusCode == 200) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Marked as read'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error marking as read: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to mark as read: $e')),
                    );
                  }
                }
              },
              child: const Icon(Icons.done_all, color: Colors.green),
            ),
          ],
        ),
      );
    },
  );
}
  Widget _buildHeroSection() {
    return Row(
      children: [
        // Problems Solved - Large
        Expanded(
          flex: 3,
          child: Container(
            height: 280,
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3366),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 6),
                right: BorderSide(color: Colors.black, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            child: const Text(
                              'PROBLEMS SOLVED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFD700),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${easy + medium + hard} / ${te + tm + th}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        size: 32,
                        color: Color(0xFFFF3366),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$solvePercentage',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 96,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            letterSpacing: -4,
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(4, 4)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        '%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: solvePercentage / 100,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD700),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'COMPLETION RATE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        Icon(Icons.trending_up, color: Colors.white, size: 20),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Rank Card
        Expanded(
          flex: 2,
          child: Container(
            height: 280,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF6C5CE7),
              border: Border(bottom: BorderSide(color: Colors.black, width: 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Column(
                    children: [
                      Text(
                        'GLOBAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'RANKING',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _formatRank(globalrank),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -2,
                          shadows: [
                            Shadow(color: Colors.black, offset: Offset(3, 3)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Active Days
        Expanded(
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF00D4FF),
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 6),
                right: BorderSide(color: Colors.black, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFF3366),
                    size: 28,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'ACTIVE DAYS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$activedays',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(3, 3)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Reputation
        Expanded(
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(
                bottom: BorderSide(color: Color(0xFFFFD700), width: 6),
                right: BorderSide(color: Colors.white, width: 3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFFFFD700)),
                  child: const Text(
                    'REPUTATION',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$reputation',
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            color: Color(0xFFFF3366),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Badges
        Expanded(
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              border: Border(bottom: BorderSide(color: Colors.black, width: 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Icon(
                    Icons.military_tech,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'BADGES',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${badges.length}',
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            shadows: [
                              Shadow(color: Colors.black, offset: Offset(3, 3)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySection() {
    return Row(
      children: [
        // Activity Chart
        Expanded(
          flex: 2,
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Text(
                    'ACTIVITY TIMELINE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CustomPaint(
                    painter: MaximalistActivityPainter(activity: activity),
                    child: Container(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Hard
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFF3366),
              border: Border(bottom: BorderSide(color: Colors.black, width: 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Text(
                    '■ HARD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$hard',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(3, 3)),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  '/ $th',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivitySection() {
    return Row(
      children: [
        // Easy
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF00E676),
              border: Border(right: BorderSide(color: Colors.black, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Text(
                    '■ EASY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFF00E676),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$easy',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(3, 3)),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  '/ $te',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Medium
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFFFB84D),
              border: Border(right: BorderSide(color: Colors.black, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Text(
                    '■ MEDIUM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$medium',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(3, 3)),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  '/ $tm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Streak
        Expanded(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFF6C5CE7)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: const Text(
                    '■ STREAK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$streak',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black, offset: Offset(3, 3)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatRank(int rank) {
    if (rank >= 1000000) {
      return '${(rank / 1000000).toStringAsFixed(1)}M';
    } else if (rank >= 1000) {
      return '${(rank / 1000).toStringAsFixed(1)}K';
    }
    return '$rank';
  }
}

class GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw diagonal lines
    for (double i = -size.height; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw circles
    final circlePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 60) {
        canvas.drawCircle(Offset(x, y), 15, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MaximalistActivityPainter extends CustomPainter {
  final Map<DateTime, int> activity;

  MaximalistActivityPainter({required this.activity});

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final List<int> last60Days = [];

    for (int i = 59; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final value = activity[date] ?? 0;
      last60Days.add(value);
    }

    if (last60Days.isEmpty) return;

    final maxValue = last60Days.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) return;

    final barWidth = size.width / last60Days.length;

    // Draw bars with heavy black borders
    for (int i = 0; i < last60Days.length; i++) {
      final value = last60Days[i];
      final normalizedHeight = (value / maxValue) * size.height * 0.85;
      final x = i * barWidth;

      // Bar background (border)
      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;

      final borderRect = Rect.fromLTWH(
        x + barWidth * 0.15,
        size.height - normalizedHeight - 2,
        barWidth * 0.7 + 2,
        normalizedHeight + 2,
      );
      canvas.drawRect(borderRect, borderPaint);

      // Bar fill
      final rect = Rect.fromLTWH(
        x + barWidth * 0.15 + 1,
        size.height - normalizedHeight,
        barWidth * 0.7,
        normalizedHeight,
      );

      // Color based on value
      Color barColor;
      if (value >= 8) {
        barColor = const Color(0xFFFF3366);
      } else if (value >= 5) {
        barColor = const Color(0xFFFFB84D);
      } else if (value >= 3) {
        barColor = const Color(0xFF00D4FF);
      } else {
        barColor = const Color(0xFF00E676);
      }

      final paint = Paint()
        ..color = barColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant MaximalistActivityPainter oldDelegate) {
    return oldDelegate.activity != activity;
  }
}
