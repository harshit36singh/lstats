// import 'dart:convert';
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
// import 'package:lstats/views/auth/pages/custombackground.dart';
// import '';

// class Homescreen extends StatefulWidget {
//   final String name;

//   const Homescreen({super.key, required this.name});

//   @override
//   State<Homescreen> createState() => _HomescreenState();
// }

// class _HomescreenState extends State<Homescreen> {
//   Map<DateTime, int> activity = {};
//   int easy = 0, medium = 0, hard = 0;
//   int globalrank = 0;
//   int activedays = 0;
//   late String res;
//   int reputation=0;
//   bool isLoading = true;
//   List<Map<String, String>> rawbadges = [];
//   List<Map<String, String>> badges = [];

//   int te = 0, tm = 0, th = 0;
//   Future<void> fetchdetails() async {
//     final String name = widget.name;
//     final uri = Uri.parse("https://lstats.onrender.com/leetcode/$name");

//     try {
//       final response = await http.get(uri);
//       print("Status: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print("Full response: $data");

//         final calendarRaw = data['calendar'];
//         Map<DateTime, int> parsedData = {};

//         if (calendarRaw != null && calendarRaw.isNotEmpty) {
//           final Map<String, dynamic> cal = json.decode(calendarRaw);
//           cal.forEach((key, value) {
//             final date = DateTime.fromMillisecondsSinceEpoch(
//               int.parse(key) * 1000,
//             );
//             final normalizedDate = DateTime(date.year, date.month, date.day);
//             int v = value as int;
//             if (v >= 10) {
//               v = 10;
//             } else if (v >= 5) {
//               v = 5;
//             } else if (v >= 3) {
//               v = 3;
//             } else if (v >= 1) {
//               v = 1;
//             } else {
//               v = 0;
//             }
//             parsedData[normalizedDate] = v;
//           });
//         }

//         setState(() {
//           easy = data['easySolved'] ?? 0;
//           medium = data['mediumSolved'] ?? 0;
//           hard = data['hardSolved'] ?? 0;
//           activity = parsedData;
//           globalrank = data['ranking'];
//           activedays = data['activeDays'];
//           te = data['easyTotal'];
//           tm = data['mediumTotal'];
//           th = data['hardTotal'];
//           res = data['profilePic'];
//           reputation=data['reputation'];

//           isLoading = false;
//           List<Map<String, dynamic>> tempBadges =
//               List<Map<String, dynamic>>.from(data['badges']);

//           badges = tempBadges.map((badge) {
//             return {
//               'icon': badge['icon'] as String,
//               'displayName': badge['displayName'] as String,
//             };
//           }).toList();

//           activity.forEach((key, value) {
//             print("${key.toIso8601String()} : $value");
//           });
//         });
//       } else {
//         print("Error: HTTP ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching details: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchdetails();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF202222),
//       body: CustomPaint(
//         painter: LinePatternPainter(),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                 child: Row(
//                   children: [
//                     // Avatar
//                     Container(
//                       width: 55,
//                       height: 55,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.transparent,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.transparent,
//                             blurRadius: 12,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       child: Center(
//                         child: isLoading
//                             ? const CircularProgressIndicator()
//                             : CircleAvatar(
//                                 radius: 30,
//                                 backgroundImage: NetworkImage(res),
//                                 backgroundColor: Colors.transparent,
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
        
//                     // Greeting text
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.name,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: -0.3,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Right icons
//                     IconButton(
//                       onPressed: () {},
//                       icon: const Icon(
//                         Iconsax.notification,
//                         color: Colors.white70,
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     IconButton(
//                       onPressed: () {},
//                       icon: const Icon(
//                         Iconsax.setting,
//                         color: Colors.white70,
//                         size: 24,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.only(
//                     left: 20,
//                     right: 20,
//                     top: 0,
//                     bottom: 90,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text(
//                         'Statistics',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFF808080),
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                       SizedBox(height: 15),
//                      _buildDottedActivityChart(),
//                       const SizedBox(height: 24),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildStatCard(
//                               icon: Icons.local_fire_department_outlined,
//                               label: 'Solved',
//                               value: "${easy + medium + hard}",
//                               bgcolor: Colors.blueGrey,
//                               btext: "out of ${te + tm + th}",
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: _buildStatCard(
//                               icon: Icons.emoji_events_outlined,
//                               label: 'Rank',
//                               value: '$globalrank',
//                               si: 28,
//                               bgcolor: Colors.teal,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       _buildScrollableCard(
//                         badges: badges,
//                         title: "Badges",
//                         bgcolor: Colors.cyanAccent,
//                       ),
//                       const SizedBox(height: 16),
//                       _buildProblemsCard(),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildStatCard(
//                               icon: Icons.calendar_today_outlined,
//                               label: 'Active Days',
//                               value: '$activedays',
//                               bgcolor: Colors.amber,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: _buildStatCard(
//                               icon: Icons.speed_outlined,
//                               label: 'Reputation',
//                               value: '$reputation',
//                               bgcolor: Colors.pinkAccent,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "Activity",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       activity.isEmpty
//                           ? const Center(
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 40),
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.black12,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.all(8),
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: HeatMap(
//                                   datasets: activity,
//                                   colorMode: ColorMode.color,
//                                   showText: false,
//                                   size: 18,
//                                   margin: const EdgeInsets.all(3),
//                                   textColor: Colors.white,
//                                   scrollable:
//                                       false, // horizontal scroll handled by parent
//                                   startDate: DateTime.now().subtract(
//                                     const Duration(days: 365),
//                                   ),
//                                   endDate: DateTime.now(),
//                                   defaultColor: Colors
//                                       .grey
//                                       .shade800, // background for inactive days
//                                   colorsets: const {
//                                     1: Color(0xFF66BB6A), // light green
//                                     3: Color(0xFF43A047), // medium green
//                                     5: Color(0xFF2E7D32), // dark green
//                                     10: Color(
//                                       0xFF1565C0,
//                                     ), // blue for high activity
//                                   },
//                                 ),
//                               ),
//                             ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildScrollableCard({
//   required String title,
//   required Color bgcolor,
//   required List<Map<String, String>> badges,
// }) {
//   return Container(
//     padding: const EdgeInsets.all(18),
//     decoration: BoxDecoration(
//       color: bgcolor,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: bgcolor.withOpacity(0.3),
//           blurRadius: 8,
//           offset: const Offset(0, 4),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               title.toUpperCase(),
//               style: const TextStyle(
//                 color: Colors.black87,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.8,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Text(
//                 "${badges.length}",
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 120,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: badges.length,
//             itemBuilder: (context, index) {
//               final badge = badges[index];
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16),
//                 child: Column(
//                   children: [
//                     Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.white.withOpacity(0.5),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.08),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                         image: DecorationImage(
//                           image: NetworkImage(badge['icon']!),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: 70,
//                       child: Text(
//                         badge['displayName']!,
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 11,
//                           color: Colors.black87,
//                           fontWeight: FontWeight.w600,
//                           height: 1.2,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }

//   Widget _buildDottedColumn({
//     required int value,
//     required int maxValue,
//     required double maxHeight,
//     required bool isPeak,
//     bool showLabel = false,
//     String labelText = '',
//   }) {
//     final columnHeight = maxValue > 0 ? (value / maxValue) * maxHeight : 0.0;
//     final dotSize = 4.0;
//     final dotSpacing = 6.5;
//     final numDots = (columnHeight / dotSpacing).floor();

//     final peakColor = const Color(0xFFFDD835);
//     final normalColor = const Color(0xFFFDD835);
//     final color = isPeak ? peakColor : normalColor;

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 2.5),
//       width: 6,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.end,
//         mainAxisSize: MainAxisSize.min,
//         children: [
          
//           SizedBox(
//             height: maxHeight,
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: List.generate(
//                   numDots,
//                   (index) => Container(
//                     width: dotSize,
//                     height: dotSize,
//                     margin: EdgeInsets.only(bottom: dotSpacing - dotSize),
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                       boxShadow: isPeak
//                           ? [
//                               BoxShadow(
//                                 color: peakColor.withOpacity(0.2),
//                                 blurRadius: 2,
//                                 spreadRadius: 0.5,
//                               ),
//                             ]
//                           : null,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDottedActivityChart() {
//     final now = DateTime.now();
//     final List<MapEntry<DateTime, int>> last60Days = [];

//     // Generate last 60 days of activity data
//     for (int i = 59; i >= 0; i--) {
//       final date = DateTime(
//         now.year,
//         now.month,
//         now.day,
//       ).subtract(Duration(days: i));
//       final value = activity[date] ?? 0;
//       last60Days.add(MapEntry(date, value));
//     }
//     final maxValue = last60Days.isEmpty
//         ? 0
//         : last60Days.map((e) => e.value).reduce((a, b) => a > b ? a : b);
//     final maxHeight = 200.0;

//     // Find peak day
//     DateTime? peakDate;
//     if (maxValue > 0) {
//       for (var entry in last60Days) {
//         if (entry.value == maxValue) {
//           peakDate = entry.key;
//           break;
//         }
//       }
//     }
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//             spreadRadius: 0,
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Total Questions',
//                 style: TextStyle(
//                   color: Color(0xFF212121),
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: -0.3,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF5F5F5),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: const [
//                     Text(
//                       'Last 60 Days',
//                       style: TextStyle(
//                         color: Color(0xFF616161),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                         letterSpacing: -0.1,
//                       ),
//                     ),
//                     SizedBox(width: 6),
//                     Icon(
//                       Icons.keyboard_arrow_down,
//                       size: 18,
//                       color: Color(0xFF616161),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 28),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             physics: const BouncingScrollPhysics(),
//             child: Column(
//               children: [
//                 // Columns
//                 SizedBox(
//                   height: maxHeight + 100,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: last60Days.asMap().entries.map((mapEntry) {
//                         final entry = mapEntry.value;
//                         final date = entry.key;
//                         final value = entry.value;
//                         final isPeak =
//                             peakDate != null &&
//                             date.year == peakDate.year &&
//                             date.month == peakDate.month &&
//                             date.day == peakDate.day;

//                         return _buildDottedColumn(
//                           value: value,
//                           maxValue: maxValue,
//                           maxHeight: maxHeight,
//                           isPeak: isPeak,
//                           showLabel: value > 0 && isPeak,
//                           labelText: '$value',
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Date labels
//                 Row(
//                   children: last60Days.asMap().entries.map((mapEntry) {
//                     final index = mapEntry.key;
//                     final date = mapEntry.value.key;

//                     final showLabel = date.day == 1 || index % 7 == 0;

//                     if (showLabel) {
//                       const monthNames = [
//                         'Jan',
//                         'Feb',
//                         'Mar',
//                         'Apr',
//                         'May',
//                         'Jun',
//                         'Jul',
//                         'Aug',
//                         'Sep',
//                         'Oct',
//                         'Nov',
//                         'Dec',
//                       ];
//                       final label = date.day == 1
//                           ? monthNames[date.month - 1]
//                           : '${date.day}';

//                       return Container(
//                         width: 6,
//                         margin: const EdgeInsets.symmetric(horizontal: 1),
//                         child: Center(
//                           child: Text(
//                             label,
//                             style: TextStyle(
//                               color: date.day == 1
//                                   ? const Color(0xFF212121)
//                                   : const Color(0xFF757575),
//                               fontSize: date.day == 1 ? 5 : 8,
//                               fontWeight: date.day == 1
//                                   ? FontWeight.w600
//                                   : FontWeight.w500,
//                               letterSpacing: -0.2,
//                             ),
//                           ),
//                         ),
//                       );
//                     }

//                     return Container(
//                       width: 6,
//                       margin: const EdgeInsets.symmetric(horizontal: 2.5),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//  Widget _buildProblemsCard() {
//   return Container(
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         colors: [
//           Colors.greenAccent.shade400,
//           Colors.greenAccent.shade200,
//         ],
//       ),
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.greenAccent.withOpacity(0.3),
//           blurRadius: 12,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               'PROBLEMS SOLVED',
//               style: TextStyle(
//                 color: Colors.black87,
//                 fontSize: 11,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.8,
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 '${easy + medium + hard}/${te + tm + th}',
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildCircularDifficulty(
//               label: 'Easy',
//               solved: easy,
//               total: te,
//               color: const Color(0xFF4CAF50),
//             ),
//             _buildCircularDifficulty(
//               label: 'Medium',
//               solved: medium,
//               total: tm,
//               color: const Color(0xFFFF9800),
//             ),
//             _buildCircularDifficulty(
//               label: 'Hard',
//               solved: hard,
//               total: th,
//               color: const Color(0xFFF44336),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildCircularDifficulty({
//   required String label,
//   required int solved,
//   required int total,
//   required Color color,
// }) {
//   final double progress = total > 0 ? solved / total : 0.0;
//   final int percentage = (progress * 100).round();

//   return Column(
//     children: [
//       Stack(
//         alignment: Alignment.center,
//         children: [
//           SizedBox(
//             width: 70,
//             height: 70,
//             child: CircularProgressIndicator(
//               value: progress,
//               strokeWidth: 6,
//               backgroundColor: Colors.white.withOpacity(0.3),
//               valueColor: AlwaysStoppedAnimation<Color>(color),
//               strokeCap: StrokeCap.round,
//             ),
//           ),
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 '$percentage%',
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   height: 1,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 '$solved/$total',
//                 style: TextStyle(
//                   color: Colors.black.withOpacity(0.6),
//                   fontSize: 9,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       const SizedBox(height: 8),
//       Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: Colors.black87,
//             fontSize: 11,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     ],
//   );
// }

//   Widget _buildStatCard({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color bgcolor,
//     double si = 36,
//     String btext = "",
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: bgcolor,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: bgcolor.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 label.toUpperCase(),
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Icon(icon, color: Colors.black87, size: 32),
//               const SizedBox(width: 12),
//               Text(
//                 value,
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: si,
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: -1.5,
//                   height: 1,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             btext,
//             style: TextStyle(
//               color: Colors.black.withOpacity(0.6),
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// // Custom painter for smooth dotted lines
// class DottedLinePainter extends CustomPainter {
//   final Color color;
//   final double dotRadius;
//   final double spacing;

//   DottedLinePainter({
//     required this.color,
//     this.dotRadius = 1.5,
//     this.spacing = 3.5,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill
//       ..isAntiAlias = true;

//     double y = 0;
//     while (y <= size.height) {
//       canvas.drawCircle(Offset(size.width / 2, y), dotRadius, paint);
//       y += spacing;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant DottedLinePainter oldDelegate) =>
//       oldDelegate.color != color ||
//       oldDelegate.dotRadius != dotRadius ||
//       oldDelegate.spacing != spacing;
// }

import 'dart:convert';
import 'dart:math' as math;
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
  int globalrank = 0;
  int activedays = 0;
  late String res;
  int reputation = 0;
  bool isLoading = true;
  List<Map<String, String>> rawbadges = [];
  List<Map<String, String>> badges = [];

  int te = 0, tm = 0, th = 0;

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
  }

  @override
  Widget build(BuildContext context) {
    final totalSolved = easy + medium + hard;
    final totalProblems = te + tm + th;
    final solvePercentage = totalProblems > 0 
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                color: Colors.transparent,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(strokeWidth: 2)
                            : CircleAvatar(
                                radius: 23,
                                backgroundImage: NetworkImage(res),
                                backgroundColor: Colors.grey[300],
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'LeetCode Stats',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      
                    
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: solvePercentage / 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.public, color: Colors.white, size: 20),
                                      const Icon(Icons.arrow_outward, color: Colors.white, size: 24),
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
                                border: Border.all(color: Colors.transparent, width: 0),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.arrow_upward, size: 32),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.all(24),
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
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    ' $reputation',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Earned',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Icon(Icons.arrow_outward, color: Colors.white, size: 24),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      painter: ActivityChartPainter(activity: activity),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
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

      canvas.drawLine(
        Offset(x, y),
        Offset(x, y - normalizedHeight),
        barPaint,
      );
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

