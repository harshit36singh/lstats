import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:lstats/views/auth/pages/loadingindicator.dart';
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
            ? BrutalistLoadingIndicator()
            : Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(
                        bottom: BorderSide(color: Colors.black, width: 4),
                        top: BorderSide(color: Colors.black, width: 4),
                        left: BorderSide(color: Colors.black, width: 4),
                        right: BorderSide(color: Colors.black, width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          decoration: BoxDecoration(
                            color: getDifficultyColor(difficulty),
                            border: const Border(
                              right: BorderSide(color: Colors.black, width: 3),
                              bottom: BorderSide(color: Colors.black, width: 3),
                            ),
                          ),
                          child: Text(
                            difficulty.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔸 Scrollable problem description
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB84D),
                        border: Border(
                          bottom: BorderSide(color: Colors.black, width: 6),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
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

                  // 🔸 Bottom action stripe
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE84855),
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                      
                        const Text(
                          "Stay consistent. Solve one daily!",
                          style: TextStyle(
                            color: Colors.white,
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
