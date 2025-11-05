import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/services/api_service.dart';
import 'package:lstats/views/auth/pages/loadingindicator.dart';
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
          'https://lstats-railway-backend-production.up.railway.app/leaderboard/global',
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
      'https://lstats-railway-backend-production.up.railway.app/friends/send?senderid=$currentuserid&receiverid=$receiverId',
    );

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "FRIEND REQUEST SENT!",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            backgroundColor: const Color(0xFF00E676),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "FAILED: ${response.body}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "ERROR: $e",
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
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
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Search Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.amber,
              border: Border(
                bottom: BorderSide(color: Colors.black, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                color: Colors.white,
              ),
              child: TextField(
                onChanged: _filter,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: 'SEARCH PLAYERS...',
                  hintStyle: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                    size: 22,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? BrutalistLoadingIndicator()
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3366),
                                border: Border.all(color: Colors.black, width: 4),
                              ),
                              child: const Icon(
                                Icons.search_off_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.black,
                              ),
                              child: Text(
                                searchQuery.isEmpty
                                    ? 'NO DATA FOUND'
                                    : 'NO USERS FOUND',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final rank = user['rank'] ?? (index + 1);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUserCard(user, rank, index),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user, int rank, int index) {
    final List<Color> colors = [
      const Color(0xFFFFD700), // Gold for top 1
      const Color(0xFFC0C0C0), // Silver for top 2
      const Color(0xFFCD7F32), // Bronze for top 3
      const Color(0xFF00D4FF),
      const Color(0xFFFF3366),
      const Color(0xFFFFB84D),
      const Color(0xFF6C5CE7),
      const Color(0xFF00E676),
      Colors.white,
    ];

    final color = index < 3 ? colors[index] : colors[(index % (colors.length - 3)) + 3];

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        children: [
          // Rank Section
          Container(
            width: 70,
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(
                right: BorderSide(color: Colors.black, width: 3),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
    
          // Avatar Section
          Container(
            width: 70,
            height: 70,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 3),
            ),
            child: Image.network(
              user['avatar'] ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
            ),
          ),
    
          // Info Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user['username'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Text(
                          '${user['points']} PTS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${user['solved']} solved',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    
          // Action Button
          Container(
            width: 60,
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(
                left: BorderSide(color: Colors.black, width: 3),
              ),
            ),
            child: GestureDetector(
               onTap: () => _showProfileDialog(user),
              child: const Center(
                child: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 4),
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Avatar
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                          user['avatar'] ?? 'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Username
                Text(
                  user['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Rank Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                  ),
                  child: Text(
                    'RANK #${user['rank'] ?? 'N/A'}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBox(
                        '${user['points'] ?? 0}',
                        'POINTS',
                        const Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatBox(
                        '${user['solved'] ?? 0}',
                        'SOLVED',
                        const Color(0xFF00E676),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (user['userid'] != null &&
                              user['userid'] != currentuserid) {
                            sendFriendRequest(user['userid']);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: user['userid'] == currentuserid
                                ? const Color(0xFFCCCCCC)
                                : const Color(0xFFFF3366),
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_add,
                                color: Colors.black,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user['userid'] == currentuserid
                                    ? 'YOU'
                                    : 'ADD FRIEND',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1,
                letterSpacing: -1,
                shadows: [
                  Shadow(
                    color: Colors.white,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}