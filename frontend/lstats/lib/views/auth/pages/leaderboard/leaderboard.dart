import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search user...',
                hintStyle: const TextStyle(color: Colors.black45),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black87, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    final first = filtered.length > 0 ? filtered[0] : null;
    final second = filtered.length > 1 ? filtered[1] : null;
    final third = filtered.length > 2 ? filtered[2] : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (second != null)
                _buildPodiumUser(second, 2, 140, const Color(0xFF94A3B8)),
              const SizedBox(width: 12),
              if (first != null)
                _buildPodiumUser(first, 1, 180, const Color(0xFFFBBF24)),
              const SizedBox(width: 12),
              if (third != null)
                _buildPodiumUser(third, 3, 120, const Color(0xFFD97706)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumUser(dynamic user, int position, double height, Color podiumColor) {
    final avatar = user['avatar'] ?? 'https://via.placeholder.com/150';
    final username = user['username'] ?? 'Unknown';
    final points = user['points'] ?? 0;

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          if (position == 1)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFBBF24).withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 20,
              ),
            ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [podiumColor, podiumColor.withOpacity(0.7)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: podiumColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: position == 1 ? 34 : 30,
                    backgroundImage: NetworkImage(avatar),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '$points',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomPaint(
            size: Size(100, height),
            painter: HexagonPodiumPainter(
              color: podiumColor,
              position: position,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final startIndex = searchQuery.isEmpty && filtered.length > 3 ? 3 : 0;
    final displayUsers = filtered.length > startIndex ? filtered.sublist(startIndex) : [];

    if (displayUsers.isEmpty) return const SizedBox.shrink();

    return Padding(
     padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        children: displayUsers.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final avatar = user['avatar'] ?? 'https://via.placeholder.com/150';
          final username = user['username'] ?? 'Unknown';
          final points = user['points'] ?? 0;
          final rank = user['rank'] ?? (startIndex + index + 1);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(avatar),
                  backgroundColor: Colors.grey.shade200,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$points',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
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
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.6),
        ],
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