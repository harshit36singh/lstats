import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lstats/services/api_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _selectedTab = 0;
  List<dynamic> friendreq = [];
  List<dynamic> friends = [];
  bool isLoading = true;
  final String baseUrl = "https://lstats-railway-backend-production.up.railway.app";

  @override
  void initState() {
    super.initState();
    _loadreq();
    _loadFriends();
  }

  Future<int?> _getuser() async {
    final i = await AuthStorage.getuserid();
    debugPrint("Loaded current user id: $i");
    return i;
  }

  Future<void> _loadreq() async {
    final id = await _getuser();
    if (id == null) {
      debugPrint("No user found");
      setState(() => isLoading = false);
      return;
    }
    try {
      final res = await http.get(Uri.parse("$baseUrl/friends/pending/$id"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          friendreq = data;
          isLoading = false;
        });
      } else {
        debugPrint("No request list found: ${res.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("This is the error : $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadFriends() async {
    final id = await _getuser();
    if (id == null) return;
    
    try {
      final res = await http.get(Uri.parse("$baseUrl/friends/list/$id"));
      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        setState(() {
          friends = data;
        });
      }
    } catch (e) {
      debugPrint("Error loading friends: $e");
    }
  }

  Future<void> _respondtoreq(int reqid, bool ans) async {
    final endpoint = ans
        ? "$baseUrl/friends/accept/$reqid"
        : "$baseUrl/friends/reject/$reqid";
    try {
      final res = await http.post(Uri.parse(endpoint));
      if (res.statusCode == 200) {
        setState(() {
          friendreq.removeWhere((r) => r['id'] == reqid);
        });
        if (ans) {
          _loadFriends();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ans ? "FRIEND ADDED!" : "REQUEST REJECTED",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            backgroundColor: ans ? const Color(0xFF00E676) : const Color(0xFFFF3366),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error while responding to request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Column(
          children: [
            _buildBrutalistHeader(),
            _buildTabSelector(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _selectedTab == 0
                    ? _buildFriendsTab()
                    : _buildRequestsTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrutalistHeader() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        color: const Color(0xFF2EDF75),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.people, color: Colors.white, size: 32),
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
                      'SOCIAL',
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
                      'FRIENDS',
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
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTab("MY FRIENDS", 0, false)),
          Container(width: 3, color: Colors.black),
          Expanded(child: _buildTab("REQUESTS", 1, true)),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index, bool showBadge) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            if (showBadge && friendreq.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3366),
                  border: Border.all(color: isSelected ? Colors.white : Colors.black, width: 2),
                ),
                child: Text(
                  '${friendreq.length}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (friends.isEmpty) {
      return Container(
        key: const ValueKey('friends-empty'),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'NO FRIENDS YET',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(color: Color(0xFFFFD700)),
                child: const Text(
                  'Start adding some friends!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('friends-list'),
      padding: EdgeInsets.zero,
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final username = friend['username'] ?? "Unknown User";
        final avatar = friend['avatar'] ?? "https://via.placeholder.com/150";
        final level = friend['level'] ?? 0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                    color: Colors.black,
                  ),
                  child: ClipRect(
                    child: Image.network(
                      avatar,
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
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(color: Colors.black),
                        child: Text(
                          username.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00D4FF),
                            ),
                            child: Text(
                              'LEVEL $level',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    if (isLoading) {
      return Container(
        key: const ValueKey('loading'),
        color: Colors.white,
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color: Color(0xFF2EDF75),
                strokeWidth: 4,
              ),
            ),
          ),
        ),
      );
    }

    if (friendreq.isEmpty) {
      return Container(
        key: const ValueKey('requests-empty'),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E676),
                  border: Border.all(color: Colors.black, width: 4),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ALL CAUGHT UP!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(color: Color(0xFFFFD700)),
                child: const Text(
                  'No pending requests',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      key: const ValueKey('requests-list'),
      padding: EdgeInsets.zero,
      itemCount: friendreq.length,
      itemBuilder: (context, index) {
        final r = friendreq[index];
        final sender = r['sender'];
        final sendername = sender?['username'] ?? "Unknown User";
        final avatar = sender?['avatar'] ?? "https://via.placeholder.com/150";

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
          ),
          margin: const EdgeInsets.all(0),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 3),
                    color: Colors.black,
                  ),
                  child: ClipRect(
                    child: Image.network(
                      avatar,
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
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(color: Colors.black),
                        child: Text(
                          sendername.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                        ),
                        child: const Text(
                          'WANTS TO BE FRIENDS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _respondtoreq(r["id"], true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _respondtoreq(r["id"], false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3366),
                      border: Border.all(color: Colors.black, width: 3),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}