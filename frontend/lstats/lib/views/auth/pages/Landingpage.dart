import 'package:flutter/material.dart';
import 'package:lstats/views/auth/login_page.dart';
// import 'package:lstats/services/first_time_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future<void> _handleGetStarted() async {
  //   await FirstTimeUserService.setNotFirstTime();
  //   if (mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF3366),
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 6),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: const Color(0xFFFFD700), width: 4),
                          ),
                          child: const Icon(
                            Icons.code,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LSTATS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -2,
                                height: 0.9,
                                shadows: [
                                  Shadow(color: Colors.black, offset: Offset(4, 4)),
                                ],
                              ),
                            ),
                            Text(
                              'TRACK • COMPETE • EXCEL',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Text(
                        'Your Ultimate LeetCode Companion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Features Grid
              Expanded(
                child: Row(
                  children: [
                    // Dashboard
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF6C5CE7),
                          border: Border(
                            right: BorderSide(color: Colors.black, width: 3),
                            bottom: BorderSide(color: Colors.black, width: 3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: const Icon(
                                Icons.dashboard,
                                color: Color(0xFF6C5CE7),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'DASHBOARD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Real-time stats & progress',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Leaderboard
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFB84D),
                          border: Border(
                            right: BorderSide(color: Colors.black, width: 3),
                            bottom: BorderSide(color: Colors.black, width: 3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: const Icon(
                                Icons.emoji_events,
                                color: Color(0xFFFFD700),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'LEADERBOARD',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Compete globally',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Row(
                  children: [
                    // Groups
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF00D4FF),
                          border: Border(
                            right: BorderSide(color: Colors.black, width: 3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: const Icon(
                                Icons.groups,
                                color: Color(0xFF00D4FF),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'GROUPS',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Team up & challenge',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Friends
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(color: Colors.black),
                              child: const Icon(
                                Icons.people,
                                color: Color(0xFF00E676),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'FRIENDS',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Connect & grow together',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // CTA Button
              GestureDetector(
                // onTap: _handleGetStarted,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: const Color(0xFFFFD700), width: 6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'GET STARTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 16),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFFFD700),
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}