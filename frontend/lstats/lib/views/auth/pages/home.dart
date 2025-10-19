import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
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
  Timer? loadingtimer;
  final random=Random();
  Map<DateTime, int> activity = {};
  int easy = 0, medium = 0, hard = 0;
  int globalrank = 0;
  int activedays = 0;
  late String res;
  int reputation = 0;
  bool isLoading = true;
  List<Map<String, String>> rawbadges = [];
  List<Map<String, String>> badges = [];
  int solvePercentage=0;

  int te = 0, tm = 0, th = 0;
  void fluxeffect(){
    loadingtimer=Timer.periodic(const Duration(milliseconds: 80),(timer){
      setState(() {
        easy = random.nextInt(500);
      medium = random.nextInt(1000);
      hard = random.nextInt(500);
      globalrank = random.nextInt(200000);
      activedays = random.nextInt(365);
      reputation = random.nextInt(100);
      solvePercentage=random.nextInt(100);
    
      

      });
    });
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

  @override
  void initState() {
    super.initState();
    fetchdetails();
  fluxeffect();
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
        backgroundColor: const Color.fromARGB(255, 46, 223, 117),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                height: 80,
                child: Stack(
                  children: [
                    // Left side background
                    Container(
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 46, 223, 117), // main color
                      ),
                    ),
                    // Right side background
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 130, // adjust based on your layout
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 47, 71, 104), // color behind the verified icon
                        ),
                      ),
                    ),
                    // Content (your row)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    )
                                  : CircleAvatar(
                                      radius: 23,
                                      backgroundImage: NetworkImage(res),
                                      backgroundColor: Colors.grey[300],
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isLoading?["Loading...", "Fetching...", "Please wait...", "Crunching data..."] [random.nextInt(4)]:
                              widget.name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Row(
              children: [
                IconButton(
                  iconSize: 29,
                  icon: const Icon(Iconsax.notification),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: Handle notification tap
                  },
                ),
                SizedBox(width: 7,),
                IconButton(
                   iconSize: 29,
                  icon: const Icon(Iconsax.setting),
                  color: Colors.white,
                  onPressed: () {
                    // TODO: Handle settings tap
                  },
                ),
              ],)
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bento Grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: [
                      // Row 1: Problems Solved + Rank
                      Row(
                        children: [
                          // Problems Solved Card
                          Expanded(
                            flex: 3,
                            child: Container(
                              height: 240,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B3D),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Problems Solved',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$solvePercentage%',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 72,
                                          fontWeight: FontWeight.w700,
                                          height: 1,
                                          letterSpacing: -3,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: solvePercentage / 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$totalSolved/$totalProblems',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(Icons.arrow_outward, size: 24),
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
                              height: 240,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE84855),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Global Rank',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatRank(globalrank),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(
                                        Icons.public,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const Icon(
                                        Icons.arrow_outward,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Row 2: Active Days + Reputation + Badges
                      Row(
                        children: [
                          // Active Days
                          Expanded(
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 0,
                                ),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.arrow_upward, size: 32),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Active Days',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$activedays',
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w700,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Icon(Icons.more_horiz, size: 24),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Reputation
                          Expanded(
                            child: Container(
                              height: 200,
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Reputation",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: AlignmentGeometry.centerLeft,
                                    child: Text(
                                      ' $reputation',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 64,
                                        fontWeight: FontWeight.w500,
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
                              height: 200,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE94196),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Badges',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${badges.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Earned',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_outward,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Row 3: Activity Chart + Hard
                      Row(
                        children: [
                          // Activity Chart
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Activity',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const Icon(Icons.verified, size: 16),
                                    ],
                                  ),
                                  Expanded(
                                    child: CustomPaint(
                                      painter: ActivityChartPainter(
                                        activity: activity,
                                      ),
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
                              height: 160,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5757),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'HARD',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    '$hard',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '/ $th',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Row 4: Easy + Medium
                      Row(
                        children: [
                          // Easy
                          Expanded(
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6BCF7F),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'EASY',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    '$easy',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '/ $te',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Medium
                          Expanded(
                            child: Container(
                              height: 160,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB84D),
                                borderRadius: BorderRadius.circular(0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'MEDIUM',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Text(
                                    '$medium',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    '/ $tm',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

// Custom painter for activity chart
class ActivityChartPainter extends CustomPainter {
  final Map<DateTime, int> activity;

  ActivityChartPainter({required this.activity});

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();
    final List<int> last60Days = [];

    // Get last 60 days of activity
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

    // Draw vertical bars
    final barWidth = size.width / last60Days.length;
    final barPaint = Paint()
      ..color = const Color(0xFF5B7C99)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < last60Days.length; i++) {
      final value = last60Days[i];
      final normalizedHeight = (value / maxValue) * size.height * 0.6;
      final x = i * barWidth + barWidth / 2;
      final y = size.height;

      canvas.drawLine(Offset(x, y), Offset(x, y - normalizedHeight), barPaint);
    }

    // Draw smooth curve
    final curvePaint = Paint()
      ..color = const Color(0xFF5B7C99)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool firstPoint = true;

    for (int i = 0; i < last60Days.length; i++) {
      final value = last60Days[i];
      final normalizedHeight = (value / maxValue) * size.height * 0.6;
      final x = i * barWidth + barWidth / 2;
      final y = size.height - normalizedHeight;

      if (firstPoint) {
        path.moveTo(x, y);
        firstPoint = false;
      } else {
        // Create smooth curve using quadratic bezier
        final prevX = (i - 1) * barWidth + barWidth / 2;
        final prevValue = last60Days[i - 1];
        final prevNormalizedHeight = (prevValue / maxValue) * size.height * 0.6;
        final prevY = size.height - prevNormalizedHeight;

        final controlX = (prevX + x) / 2;
        final controlY = (prevY + y) / 2;

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    canvas.drawPath(path, curvePaint);
  }

  @override
  bool shouldRepaint(covariant ActivityChartPainter oldDelegate) {
    return oldDelegate.activity != activity;
  }
}
