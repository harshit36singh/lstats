import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({Key? key}) : super(key: key);

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  String title = '';
  String difficulty = '';
  String link = '';
  String content = '';
  bool isLoading = true;

  Future<void> fetchDailyChallenge() async {
    final response =
        await http.get(Uri.parse('https://leetcode-api-pied.vercel.app/daily'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final question = data['question'];

      setState(() {
        title = question['title'] ?? 'No Title';
        difficulty = question['difficulty'] ?? 'Unknown';
        link = "https://leetcode.com${data['link'] ?? ''}";
        content = question['content'] ?? '<p>No description available.</p>';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDailyChallenge();
  }

  Color getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF6BCF7F);
      case 'medium':
        return const Color(0xFFFFB84D);
      case 'hard':
        return const Color(0xFFE84855);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            : Column(
                children: [
                  // Stripe 1: Header
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFF6B3D),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.02,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Daily Challenge',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.082,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                  ),

                  // Stripe 2: Title + Difficulty
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.015,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 14,
                          ),
                          decoration: BoxDecoration(
                            color: getDifficultyColor(difficulty),
                         
                          ),
                          child: Text(
                            difficulty,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stripe 3: Scrollable description
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFFFB84D),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.02,
                      ),
                      child: SingleChildScrollView(
                        child: Html(
                          data: content,
                          style: {
                            "body": Style(
                              color: Colors.black,
                              fontSize: FontSize(screenWidth * 0.04),
                              fontWeight: FontWeight.w500,
                              lineHeight: LineHeight.em(1.4),
                            ),
                          },
                        ),
                      ),
                    ),
                  ),

                  // Stripe 4: Bottom stripe with Solve + footer text
                  Container(
                    color: const Color(0xFFE84855),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    child: Column(
                      children: [
                      
                        Text(
                          "Stay consistent. Solve one daily!",
                          style: TextStyle(
                            color: const Color(0xFFFAFAFA),
                            fontSize: screenWidth * 0.035,
                            fontWeight: FontWeight.w500,
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
}
