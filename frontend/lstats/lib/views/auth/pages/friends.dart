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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadreq();
    _loadFriends();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            backgroundColor: ans ? const Color(0xFF6BCF7F) : const Color(0xFFE84855),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header - Orange stripe
              Container(
                width: double.infinity,
                color: const Color(0xFFFF6B3D),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SOCIAL",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Connect & Compete',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (friendreq.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE84855),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${friendreq.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      
              // Tab Selector - Yellow stripe
              Container(
                width: double.infinity,
                color: const Color(0xFFFFB84D),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTab("FRIENDS", 0)),
                      Container(width: 2.5, color: Colors.black),
                      Expanded(child: _buildTab("REQUESTS", 1)),
                      Container(width: 2.5, color: Colors.black),
                      Expanded(child: _buildTab("SEARCH", 2)),
                    ],
                  ),
                ),
              ),
      
              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _selectedTab == 0
                      ? _buildFriendsTab()
                      : _selectedTab == 1
                          ? _buildRequestsTab()
                          : _buildSearchTab(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.black,
            letterSpacing: 0.5,
          ),
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
              Icon(
                Icons.people_outline,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'NO FRIENDS YET',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start adding some friends!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<Color> stripeColors = [
      const Color(0xFFFF6B3D),
      const Color(0xFFFFB84D),
      Colors.white,
      
      const Color(0xFFE84855),
      const Color(0xFFE94196),
      const Color(0xFF6BCF7F),
    ];

    return ListView.builder(
      key: const ValueKey('friends-list'),
      padding: EdgeInsets.zero,
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        final username = friend['username'] ?? "Unknown User";
        final avatar = friend['avatar'] ?? "https://via.placeholder.com/150";
        final color = stripeColors[index % stripeColors.length];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          color: color,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(avatar),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level ${friend['level'] ?? '?'}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
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
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B3D),
            strokeWidth: 4,
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
              Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'ALL CAUGHT UP!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No pending requests',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final List<Color> stripeColors = [
      const Color(0xFFFF6B3D),
      Colors.white,
      const Color(0xFFFFB84D),
      const Color(0xFFE84855),
      const Color(0xFFE94196),
      const Color(0xFF6BCF7F),
    ];

    return ListView.builder(
      key: const ValueKey('requests-list'),
      padding: EdgeInsets.zero,
      itemCount: friendreq.length,
      itemBuilder: (context, index) {
        final r = friendreq[index];
        final sender = r['sender'];
        final sendername = sender?['username'] ?? "Unknown User";
        final avatar = sender?['avatar'] ?? "https://via.placeholder.com/150";
        final color = stripeColors[index % stripeColors.length];

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          color: color,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(avatar),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sendername,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Wants to be friends',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _respondtoreq(r["id"], true),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6BCF7F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _respondtoreq(r["id"], false),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE84855),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Container(
      key: const ValueKey('search'),
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2.5),
              color: Colors.white,
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Search for players...',
                hintStyle: const TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontWeight: FontWeight.w600,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        child: const Icon(Icons.clear, color: Colors.black),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (value) {
                debugPrint("Searching for: $value");
              },
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FIND NEW FRIENDS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for players to add',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}