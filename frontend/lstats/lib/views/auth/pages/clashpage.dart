import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;


class LeetCodeClash extends StatefulWidget {
  const LeetCodeClash({super.key});

  @override
  State<LeetCodeClash> createState() => _LeetCodeClashState();
}

class _LeetCodeClashState extends State<LeetCodeClash> {
  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();

  Map<String, dynamic>? player1Data;
  Map<String, dynamic>? player2Data;
  bool isLoading = false;
  String? errorMessage;

  Future<Map<String, dynamic>?> fetchPlayerData(String username) async {
    try {
      final response = await http.get(
        Uri.parse('https://lstats.onrender.com/leetcode/$username'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching $username: $e');
      return null;
    }
  }

  Future<void> startClash() async {
    if (player1Controller.text.isEmpty || player2Controller.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both usernames';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      player1Data = null;
      player2Data = null;
    });

    final results = await Future.wait([
      fetchPlayerData(player1Controller.text.trim()),
      fetchPlayerData(player2Controller.text.trim()),
    ]);

    setState(() {
      player1Data = results[0];
      player2Data = results[1];
      isLoading = false;

      if (player1Data == null || player2Data == null) {
        errorMessage = 'Failed to fetch one or both players';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFFF6B3D),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  const Text(
                    '⚔️ LEETCODE CLASH',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1 VS 1',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),

            // Input Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.5),
                          ),
                          child: TextField(
                            controller: player1Controller,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Player 1 Username',
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: Icon(Icons.person, color: Colors.black),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: Colors.black, width: 2.5),
                        ),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.5),
                          ),
                          child: TextField(
                            controller: player2Controller,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Player 2 Username',
                              hintStyle: TextStyle(
                                color: Color(0xFFCCCCCC),
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: Icon(Icons.person, color: Colors.black),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: isLoading ? null : startClash,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isLoading ? Colors.grey : const Color(0xFFE84855),
                        border: Border.all(color: Colors.black, width: 2.5),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'START CLASH',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Comparison Results
            if (player1Data != null && player2Data != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPlayerHeaders(),
                      _buildComparisonRow(
                        'TOTAL SOLVED',
                        player1Data!['easySolved'] +
                            player1Data!['mediumSolved'] +
                            player1Data!['hardSolved'],
                        player2Data!['easySolved'] +
                            player2Data!['mediumSolved'] +
                            player2Data!['hardSolved'],
                        const Color(0xFFFF6B3D),
                      ),
                      _buildComparisonRow(
                        'EASY',
                        player1Data!['easySolved'],
                        player2Data!['easySolved'],
                        const Color(0xFF6BCF7F),
                      ),
                      _buildComparisonRow(
                        'MEDIUM',
                        player1Data!['mediumSolved'],
                        player2Data!['mediumSolved'],
                        const Color(0xFFFFB84D),
                      ),
                      _buildComparisonRow(
                        'HARD',
                        player1Data!['hardSolved'],
                        player2Data!['hardSolved'],
                        const Color(0xFFFF5757),
                      ),
                      _buildComparisonRow(
                        'GLOBAL RANK',
                        player1Data!['ranking'],
                        player2Data!['ranking'],
                        const Color(0xFFE94196),
                        lowerIsBetter: true,
                      ),
                      _buildComparisonRow(
                        'ACTIVE DAYS',
                        player1Data!['activeDays'],
                        player2Data!['activeDays'],
                        const Color(0xFF5B7C99),
                      ),
                      _buildComparisonRow(
                        'REPUTATION',
                        player1Data!['reputation'],
                        player2Data!['reputation'],
                        const Color(0xFFFFD700),
                      ),
                      _buildComparisonRow(
                        'BADGES',
                        (player1Data!['badges'] as List).length,
                        (player2Data!['badges'] as List).length,
                        const Color(0xFFE84855),
                      ),
                      _buildWinnerSection(),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_mma,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'READY TO CLASH?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.grey[600],
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter two usernames to start',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHeaders() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.5),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      player1Data!['profilePic'] ?? 'https://via.placeholder.com/150',
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  player1Data!['username'] ?? 'Player 1',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2.5),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      player2Data!['profilePic'] ?? 'https://via.placeholder.com/150',
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  player2Data!['username'] ?? 'Player 2',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    int value1,
    int value2,
    Color color, {
    bool lowerIsBetter = false,
  }) {
    final bool player1Wins = lowerIsBetter ? value1 < value2 : value1 > value2;
    final bool isDraw = value1 == value2;

    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDraw
                        ? Colors.grey[700]
                        : player1Wins
                            ? Colors.black
                            : Colors.white,
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      _formatNumber(value1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDraw
                            ? Colors.white
                            : player1Wins
                                ? Colors.white
                                : Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                child: Icon(
                  isDraw ? Icons.horizontal_rule : Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isDraw
                        ? Colors.grey[700]
                        : player1Wins
                            ? Colors.white
                            : Colors.black,
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                  child: Center(
                    child: Text(
                      _formatNumber(value2),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDraw
                            ? Colors.white
                            : player1Wins
                                ? Colors.black
                                : Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }Widget _buildWinnerSection() {
  final p1 = player1Data!;
  final p2 = player2Data!;

  int easy1 = p1['easySolved'];
  int medium1 = p1['mediumSolved'];
  int hard1 = p1['hardSolved'];

  int easy2 = p2['easySolved'];
  int medium2 = p2['mediumSolved'];
  int hard2 = p2['hardSolved'];

  int total1 = easy1 + medium1 + hard1;
  int total2 = easy2 + medium2 + hard2;

  double difficultyIndex1 =
      (easy1 * 3 + medium1 * 4 + hard1 * 5) / (total1 == 0 ? 1 : total1);
  double difficultyIndex2 =
      (easy2 * 3 + medium2 * 4 + hard2 * 5) / (total2 == 0 ? 1 : total2);

  double engagement1 = (p1['activeDays'] * 0.7) + (p1['reputation'] * 0.3);
  double engagement2 = (p2['activeDays'] * 0.7) + (p2['reputation'] * 0.3);

  double rankScore1 = 1 / (p1['ranking'] + 1);
  double rankScore2 = 1 / (p2['ranking'] + 1);

  double power1 = (difficultyIndex1 * 10) +
      (engagement1 * 0.03) +
      (rankScore1 * 40000);
  double power2 = (difficultyIndex2 * 10) +
      (engagement2 * 0.03) +
      (rankScore2 * 40000);

  final winner = power1 > power2
      ? p1['username']
      : power2 > power1
          ? p2['username']
          : null;

  final loser = winner == p1['username'] ? p2 : p1;

  final color = winner == p1['username']
      ? const Color(0xFF6BCF7F)
      : winner == p2['username']
          ? const Color(0xFFE84855)
          : const Color(0xFFFFB84D);

  // Suggestion Logic
  String suggestion = _generateImprovementSuggestion(loser);

  return Column(
    children: [
      Container(
        width: double.infinity,
        color: color,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.analytics, size: 64, color: Colors.black),
            const SizedBox(height: 16),
            Text(
              winner == null ? "IT'S A TIE!" : "$winner WINS!",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "POWER SCORE: ${power1.toStringAsFixed(1)} - ${power2.toStringAsFixed(1)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      _buildAnalyticsSection(p1, p2, difficultyIndex1, difficultyIndex2),
      _buildVisualAnalytics(p1, p2, difficultyIndex1, difficultyIndex2, power1, power2),
      _buildImprovementSection(loser['username'], suggestion),
    ],
  );
}

String _generateImprovementSuggestion(Map<String, dynamic> player) {
  final int total = player['easySolved'] + player['mediumSolved'] + player['hardSolved'];
  final double hardRatio = total == 0 ? 0 : player['hardSolved'] / total;
  final double mediumRatio = total == 0 ? 0 : player['mediumSolved'] / total;
  final int activeDays = player['activeDays'];
  final int reputation = player['reputation'];
  final int ranking = player['ranking'];

  if (hardRatio < 0.1) {
    return "Focus on tackling more hard problems to boost difficulty mastery.";
  } else if (mediumRatio < 0.3) {
    return "Try to maintain a consistent medium problem practice routine.";
  } else if (activeDays < 30) {
    return "Increase daily activity — even small streaks improve performance.";
  } else if (reputation < 100) {
    return "Engage more in discussions and share solutions to build reputation.";
  } else if (ranking > 100000) {
    return "Consider joining contests to improve your global ranking.";
  } else {
    return "Keep refining your problem-solving efficiency and balance.";
  }
}

Widget _buildImprovementSection(String playerName, String suggestion) {
  return Container(
    color: const Color(0xFF222222),
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "💡 HOW $playerName CAN IMPROVE",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          suggestion,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );
}

Widget _buildVisualAnalytics(
  Map<String, dynamic> p1,
  Map<String, dynamic> p2,
  double diff1,
  double diff2,
  double power1,
  double power2,
) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📈 VISUAL COMPARISON",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        _buildBar("Difficulty Index", diff1, diff2, maxValue: 5),
        _buildBar("Power Score", power1, power2, maxValue: 100),
        _buildBar("Active Days", p1['activeDays'].toDouble(), p2['activeDays'].toDouble()),
        _buildBar("Reputation", p1['reputation'].toDouble(), p2['reputation'].toDouble()),
      ],
    ),
  );
}

Widget _buildBar(String label, double val1, double val2, {double maxValue = 100}) {
  final double p1Percent = (val1 / maxValue).clamp(0.0, 1.0);
  final double p2Percent = (val2 / maxValue).clamp(0.0, 1.0);

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: 12,
                    width: 200 * p1Percent,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(val1.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: 12,
                    width: 200 * p2Percent,
                    decoration: BoxDecoration(
                      color: Colors.redAccent[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(val2.toStringAsFixed(1),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

Widget _buildAnalyticsSection(
  Map<String, dynamic> p1,
  Map<String, dynamic> p2,
  double diff1,
  double diff2,
) {
  // Ratios for deeper comparison
  int total1 = p1['easySolved'] + p1['mediumSolved'] + p1['hardSolved'];
  int total2 = p2['easySolved'] + p2['mediumSolved'] + p2['hardSolved'];

  double hardRatio1 = total1 == 0 ? 0 : p1['hardSolved'] / total1;
  double hardRatio2 = total2 == 0 ? 0 : p2['hardSolved'] / total2;

  double mediumRatio1 = total1 == 0 ? 0 : p1['mediumSolved'] / total1;
  double mediumRatio2 = total2 == 0 ? 0 : p2['mediumSolved'] / total2;

  double easyRatio1 = total1 == 0 ? 0 : p1['easySolved'] / total1;
  double easyRatio2 = total2 == 0 ? 0 : p2['easySolved'] / total2;

  String insight = '';
  if (hardRatio1 > hardRatio2) {
    insight = '${p1['username']} tends to solve harder problems more often.';
  } else if (hardRatio2 > hardRatio1) {
    insight = '${p2['username']} prefers tougher challenges.';
  } else if (mediumRatio1 > mediumRatio2) {
    insight = '${p1['username']} has stronger medium-difficulty balance.';
  } else if (mediumRatio2 > mediumRatio1) {
    insight = '${p2['username']} shows more balanced problem-solving.';
  } else {
    insight = 'Both have similar difficulty distribution and consistency.';
  }

  return Container(
    width: double.infinity,
    color: Colors.black,
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 ANALYTICS SUMMARY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Difficulty Index: ${diff1.toStringAsFixed(2)} vs ${diff2.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Hard Problem Ratio: ${(hardRatio1 * 100).toStringAsFixed(1)}% vs ${(hardRatio2 * 100).toStringAsFixed(1)}%',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Engagement: ${p1['activeDays']} days / ${p1['reputation']} rep vs ${p2['activeDays']} days / ${p2['reputation']} rep',
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Text(
          'Insight: $insight',
          style: const TextStyle(
            color: Colors.amberAccent,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }
}