import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;
  List<dynamic> filtered = [];
  String searchQuery = '';
  int? currentuserid;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
    loadcurrentuser();
  }

  Future<void> loadcurrentuser() async {
    final id = await AuthStorage.getuserid();
    setState(() {
      currentuserid = id;
    });
    print("Loaded current user id: $currentuserid");
  }

  Future<void> fetchLeaderboard() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://lstatsbackend-production.up.railway.app/leaderboard/global',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          leaderboard = data;
          filtered = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leaderboard');
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> sendFriendRequest(int receiverId) async {
    print("receiverid : $receiverId");
    if (currentuserid == null) return;

    final url = Uri.parse(
      'https://lstatsbackend-production.up.railway.app/friends/send?senderid=$currentuserid&receiverid=$receiverId',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Friend request sent!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _refreshData() async {
    try {
      await http.post(
        Uri.parse(
          'https://lstatsbackend-production.up.railway.app/leaderboard/refresh',
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

  void _filter(String query) {
    setState(() {
      searchQuery = query;
      filtered = leaderboard
          .where(
            (u) => u['username'].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
         Padding(
  padding: const EdgeInsets.all(16),
  child: Expanded(
    child: TextField(
      onChanged: _filter,
      decoration: InputDecoration(
        hintText: 'Search user...',
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
         
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
         
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
         
          borderSide: const BorderSide(color: Colors.black87, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
  ),
),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.black87),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'No data found'
                              : 'No users found for "$searchQuery"',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (searchQuery.isEmpty && filtered.length >= 3)
                          _buildPodium(),
                        _buildLeaderboardList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

Widget _buildPodium() {
  final first = filtered.isNotEmpty ? filtered[0] : null;
  final second = filtered.length > 1 ? filtered[1] : null;
  final third = filtered.length > 2 ? filtered[2] : null;

  TextStyle rankStyle = const TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w900,
    color: Colors.black,
    letterSpacing: -2,
  );

  TextStyle nameStyle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  TextStyle pointsStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  return Column(
    children: [
      if (first != null)
        Container(
          width: double.infinity,
          color: const Color(0xFFE6542B),
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            children: [
              Text("1", style: rankStyle),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(
                  first['avatar'] ?? 'https://via.placeholder.com/150',
                ),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(first['username'] ?? 'Unknown', style: nameStyle),
              Text("${first['points']} pts", style: pointsStyle),
            ],
          ),
        ),
      Row(
        children: [
          if (second != null)
            Expanded(
              child: Container(
                color: const Color(0xFF03A9F4),
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    Text("2", style: rankStyle.copyWith(fontSize: 60)),
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        second['avatar'] ??
                            'https://via.placeholder.com/150',
                      ),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(second['username'] ?? 'Unknown', style: nameStyle),
                    Text("${second['points']} pts", style: pointsStyle),
                  ],
                ),
              ),
            ),
          if (third != null)
            Expanded(
              child: Container(
                color: const Color(0xFFFFC107),
                padding: const EdgeInsets.symmetric(vertical: 25),
                child: Column(
                  children: [
                    Text("3", style: rankStyle.copyWith(fontSize: 60)),
                    const SizedBox(height: 4),
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        third['avatar'] ??
                            'https://via.placeholder.com/150',
                      ),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(third['username'] ?? 'Unknown', style: nameStyle),
                    Text("${third['points']} pts", style: pointsStyle),
                  ],
                ),
              ),
            ),
        ],
      ),
    ],
  );
}


 Widget _buildLeaderboardList() {
  final startIndex = searchQuery.isEmpty && filtered.length > 3 ? 3 : 0;
  final displayUsers = filtered.length > startIndex
      ? filtered.sublist(startIndex)
      : [];

  if (displayUsers.isEmpty) return const SizedBox.shrink();

  // A set of nice, solid accent colors
  final List<Color> solidColors = [
  const Color(0xFFDFAF00), // Muted Amber
  const Color(0xFF64B5F6), // Soft Blue
  const Color(0xFF81C784), // Soft Green
  const Color(0xFFFF8A65), // Muted Orange
  const Color(0xFF9575CD), // Soft Purple
  const Color(0xFFF48FB1), // Soft Pink
  const Color(0xFF4DD0E1), // Muted Cyan
  const Color(0xFF66BB6A), // Muted Green
  const Color(0xFFFFB74D), // Soft Orange
  const Color(0xFF42A5F5), // Soft Blue
];


  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    itemCount: displayUsers.length,
    itemBuilder: (context, index) {
      final user = displayUsers[index];
      final rank = startIndex + index + 1;
      final color = solidColors[index % solidColors.length]; // cycle colors

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          // No margin, no border radius → seamless stacked blocks
        ),
        child: Row(
          children: [
            Text(
              '$rank',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 14),
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                user['avatar'] ?? 'https://via.placeholder.com/150',
              ),
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user['username'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${user['points']} pts",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  void _showProfileDialog(user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(10),
          ),

          child: Container(),
        );
      },
    );
  }
}

class HexagonPodiumPainter extends CustomPainter {
  final Color color;
  final int position;

  HexagonPodiumPainter({required this.color, required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final shadowPath = Path();

    final topWidth = size.width * 0.85;
    final bottomWidth = size.width;
    final centerX = size.width / 2;

    shadowPath.moveTo(centerX - bottomWidth / 2 + 4, size.height + 4);
    shadowPath.lineTo(centerX - topWidth / 2 + 4, 4);
    shadowPath.lineTo(centerX + topWidth / 2 + 4, 4);
    shadowPath.lineTo(centerX + bottomWidth / 2 + 4, size.height + 4);
    shadowPath.close();

    path.moveTo(centerX - bottomWidth / 2, size.height);
    path.lineTo(centerX - topWidth / 2, 0);
    path.lineTo(centerX + topWidth / 2, 0);
    path.lineTo(centerX + bottomWidth / 2, size.height);
    path.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$position',
        style: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w900,
          color: Colors.white.withOpacity(0.25),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX - textPainter.width / 2,
        size.height / 2 - textPainter.height / 2 - 10,
      ),
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final highlightPath = Path();
    highlightPath.moveTo(centerX - topWidth / 2, 0);
    highlightPath.lineTo(centerX + topWidth / 2, 0);

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
