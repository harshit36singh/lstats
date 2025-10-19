import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CollegeLeaderboard extends StatefulWidget {
  const CollegeLeaderboard({super.key});

  @override
  State<CollegeLeaderboard> createState() => _CollegeLeaderboardState();
}

class _CollegeLeaderboardState extends State<CollegeLeaderboard> {
  List<dynamic> colleges = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchColleges();
  }

  Future<void> fetchColleges() async {
    final url = 'https://lstatsbackend-production.up.railway.app/leaderboard/colleges';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          colleges = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B3D),
            strokeWidth: 4,
          ),
        ),
      );
    }
    if (colleges.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.abc_rounded, size: 80, color: Color(0xFFCCCCCC)),
              SizedBox(height: 16),
              Text(
                'NO COLLEGES FOUND',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1,
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
      padding: EdgeInsets.zero,
      itemCount: colleges.length,
      itemBuilder: (context, index) {
        final college = colleges[index];
        final collegeName = college['college'] ?? 'Unknown';
        final points = college['points'] ?? 0;
        final rank = college['rank'] ?? (index + 1);
        final color = stripeColors[index % stripeColors.length];

        return GestureDetector(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => CollegeDetailPage(collegeName: collegeName),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: color,
            ),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    collegeName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$points',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.black,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CollegeDetailPage extends StatefulWidget {
  final String collegeName;
  const CollegeDetailPage({super.key, required this.collegeName});

  @override
  State<CollegeDetailPage> createState() => _CollegeDetailPageState();
}

class _CollegeDetailPageState extends State<CollegeDetailPage> {
  List<dynamic> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCollegeStudents();
  }

  Future<void> fetchCollegeStudents() async {
    final url = 'https://lstatsbackend-production.up.railway.app/leaderboard/college?college=${Uri.encodeComponent(widget.collegeName)}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          students = json.decode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true, // This allows content to extend behind bottom nav if present
      body: Column(
        children: [
          // Header - Orange stripe
          Container(
            width: double.infinity,
            color: const Color(0xFFFF6B3D),
            padding: const EdgeInsets.only(
              left: 12,
              right: 20,
              top: 50,
              bottom: 20,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.collegeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isLoading)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${students.length} STUDENTS',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: isLoading
                ? Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B3D),
                        strokeWidth: 4,
                      ),
                    ),
                  )
                : students.isEmpty
                    ? Container(
                        color: Colors.white,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_off,
                                size: 80,
                                color: Color(0xFFCCCCCC),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'NO STUDENTS FOUND',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    final List<Color> stripeColors = [
      const Color(0xFFFF6B3D),
      Colors.white,
      const Color(0xFFFFB84D),
      const Color(0xFFE84855),
      const Color(0xFFE94196),
      const Color(0xFF6BCF7F),
    ];

    // Show podium if we have top 3
    final hasPodium = students.length >= 3;

    return SingleChildScrollView(
      child: Column(
        children: [
          if (hasPodium) _buildPodium(),
          _buildRegularList(hasPodium ? 3 : 0, stripeColors),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final first = students[0];
    final second = students.length > 1 ? students[1] : null;
    final third = students.length > 2 ? students[2] : null;

    return Column(
      children: [
        // First Place
        Container(
          width: double.infinity,
          color: const Color(0xFFFFD700),
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 3),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 38,
                  backgroundImage: NetworkImage(
                    first['avatar'] ?? 'https://via.placeholder.com/150',
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      first['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Solved: ${first['solved'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
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
                  '${first['points']} pts',
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

        // Second and Third
        Row(
          children: [
            if (second != null)
              Expanded(
                child: Container(
                  color: const Color(0xFFC0C0C0),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '2',
                            style: TextStyle(
                              fontSize: 26,
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
                          radius: 32,
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
                            fontSize: 15,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (third != null)
              Expanded(
                child: Container(
                  color: const Color(0xFFCD7F32),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              fontSize: 26,
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
                          radius: 32,
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
                            fontSize: 15,
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
                          fontSize: 13,
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

  Widget _buildRegularList(int startIndex, List<Color> colors) {
    if (students.length <= startIndex) return const SizedBox.shrink();

    final displayStudents = students.sublist(startIndex);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: displayStudents.length,
      itemBuilder: (context, index) {
        final user = displayStudents[index];
        final rank = startIndex + index + 1;
        final color = colors[index % colors.length];

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Solved: ${user['solved'] ?? 0}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
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
                  '${user['points']} pts',
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
}