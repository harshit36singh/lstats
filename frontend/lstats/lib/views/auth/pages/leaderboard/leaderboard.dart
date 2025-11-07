import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/services/api_service.dart';
import 'package:lstats/views/auth/pages/loadingindicator.dart';

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
  }

  Future<void> sendinviteuser(int groupid,String sender,String receiver)async{
  final res=await http.post(Uri.parse('https://lstats-railway-backend-production.up.railway.app/groups/$groupid/invite'
      '?sender=$sender&receiver=$receiver'));
      

      if(res.statusCode==200){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sent the invite successfully."),backgroundColor: Colors.green,));

      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error:${res.body}")));
      }

}

  Future<void> showgrouppicker(BuildContext context, String receiver) async {
    final currentuser = await AuthStorage.getUsername();

    if (currentuser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "USER NOT LOGGED IN",
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
      return;
    }

    final res = await http.get(
      Uri.parse(
        "https://lstats-railway-backend-production.up.railway.app/groups/my?name=$currentuser",
      ),
    );

    if (res.statusCode == 200) {
      final g = jsonDecode(res.body);

      if (g.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "NO GROUPS FOUND",
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            backgroundColor: const Color(0xFFFFB84D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
          ),
        );
        return;
      }

      // Show brutalist dialog instead of modal sheet
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 500),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D4FF),
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
                          Icons.group,
                          color: Color(0xFF00D4FF),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'SELECT GROUP',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtitle
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 3),
                    ),
                  ),
                  child: Text(
                    'INVITE $receiver TO GROUP',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Groups List
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: g.length,
                    itemBuilder: (_, i) {
                      final group = g[i];
                      return GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          await sendinviteuser(group["id"], currentuser, receiver);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Group Icon
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6C5CE7),
                                  ),
                                  child: const Icon(
                                    Icons.people,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Group Name
                                Expanded(
                                  child: Text(
                                    group["name"].toString().toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                
                                // Arrow
                                const Icon(
                                  Icons.arrow_forward,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "FAILED TO LOAD GROUPS",
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
          // Minimal search bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
                color: const Color(0xFFF8F9FA),
              ),
              child: TextField(
                onChanged: _filter,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black54,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: isLoading
                ? BrutalistLoadingIndicator()
                : filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final user = filtered[index];
                          final rank = user['rank'] ?? (index + 1);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildUserCard(user, rank, index),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              color: Colors.white,
            ),
            child: const Icon(
              Icons.search_off,
              size: 48,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(color: Colors.black),
            child: Text(
              searchQuery.isEmpty ? 'NO DATA' : 'NO USERS FOUND',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user, int rank, int index) {
    final bool iscurrentuser = user['id'] == currentuserid;

    Color rankColor;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankColor = const Color(0xFFE0E0E0);
    } else if (rank == 3) {
      rankColor = const Color(0xFFFFB84D);
    } else {
      rankColor = Colors.white;
    }

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: iscurrentuser ? const Color(0xFF00E676) : Colors.black,
          width: iscurrentuser ? 2.5 : 1.5,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 50,
            decoration: BoxDecoration(
              color: rankColor,
              border: Border(
                right: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Avatar
          Container(
            width: 50,
            height: 50,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Image.network(
              user['avatar'] ?? 'https://via.placeholder.com/150',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: Colors.black54,
                  ),
                );
              },
            ),
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    iscurrentuser ? 'You' : (user['username'] ?? 'Unknown'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: const BoxDecoration(color: Colors.black),
                        child: Text(
                          '${user['points']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${user['solved']} solved',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // More button
          if (!iscurrentuser)
            GestureDetector(
              onTap: () => _showProfileDialog(user),
              child: Container(
                width: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    left: BorderSide(color: Colors.black, width: 1.5),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.more_vert, color: Colors.white, size: 20),
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
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Avatar and Close
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
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: Image.network(
                          user['avatar'] ?? 'https://via.placeholder.com/150',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Username and Rank
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (user['username'] ?? 'Unknown').toString().toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: Text(
                                'RANK #${user['rank'] ?? 'N/A'}',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Close button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Section
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Stats Label
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(color: Colors.black),
                        child: const Text(
                          'STATISTICS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Stats Boxes
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              '${user['points'] ?? 0}',
                              'POINTS',
                              const Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatBox(
                              '${user['solved'] ?? 0}',
                              'SOLVED',
                              const Color(0xFF00E676),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      // Add Friend Button
                      GestureDetector(
                        onTap: () {
                          if (user['id'] != null &&
                              user['id'] != currentuserid) {
                            sendFriendRequest(user['id']);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'ADD FRIEND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Invite to Group Button
                      GestureDetector(
                        onTap: () {
                          showgrouppicker(context, user['username']);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4FF),
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_add,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'INVITE TO GROUP',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  letterSpacing: 1.5,
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
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}