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
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFF6B3D),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
               
               
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2.5),
                    color: Colors.white,
                  ),
                  child: TextField(
                    onChanged: _filter,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search players...',
                      hintStyle: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF6B3D),
                      strokeWidth: 4,
                    ),
                  )
                : filtered.isEmpty
                    ? Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 80,
                                color: Color(0xFFCCCCCC),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'NO DATA FOUND'
                                    : 'NO USERS FOUND',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
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

    return Column(
      children: [
        // First Place - Full width
        if (first != null)
          Container(
            width: double.infinity,
            color: const Color(0xFFFFD700),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage: NetworkImage(
                      first['avatar'] ?? 'https://via.placeholder.com/150',
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first['username'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${first['points']} POINTS',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Colors.black,
                ),
              ],
            ),
          ),

        // Second and Third Place
        Row(
          children: [
            // Second Place
            if (second != null)
              Expanded(
                child: Container(
                  color: const Color(0xFFC0C0C0),
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFC0C0C0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.5),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            second['avatar'] ?? 'https://via.placeholder.com/150',
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          second['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${second['points']} pts',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Third Place
            if (third != null)
              Expanded(
                child: Container(
                  color: const Color(0xFFCD7F32),
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFCD7F32),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2.5),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(
                            third['avatar'] ?? 'https://via.placeholder.com/150',
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          third['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${third['points']} pts',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
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

    final List<Color> stripeColors = [
      const Color(0xFFFF6B3D),
      Colors.white,
      const Color(0xFFFFB84D),
      const Color(0xFFE84855),
      const Color(0xFFE94196),
      const Color(0xFF6BCF7F),
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: displayUsers.length,
      itemBuilder: (context, index) {
        final user = displayUsers[index];
        final rank = startIndex + index + 1;
        final color = stripeColors[index % stripeColors.length];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: color,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    user['avatar'] ?? 'https://via.placeholder.com/150',
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  user['username'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${user['points']} pts",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5,
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(),
        );
      },
    );
  }
}