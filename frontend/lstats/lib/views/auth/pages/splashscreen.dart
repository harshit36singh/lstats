import 'package:flutter/material.dart';
import 'package:lstats/viewmodels/auth_viewmodels.dart';
import 'package:lstats/views/auth/pages/pagenav.dart';
import 'package:lstats/views/auth/login_page.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blocksAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _blocksAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOutCubic),
      ),
    );

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final auth = Provider.of<AuthViewModel>(context, listen: false);

    _controller.forward();
    await auth.loadUser();
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    final targetPage = (auth.token != null && auth.token!.isNotEmpty)
        ? MainNavPage(uname: auth.username ?? '')
        : const LoginPage();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => targetPage,
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // Expanding colored grid background
                CustomPaint(
                  size: size,
                  painter: GridBlockPainter(progress: _blocksAnimation.value),
                ),

                // Central LS logo
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(48),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ClipRRect(
                        // borderRadius: BorderRadius.circular(48),
                        child: Image.asset(
                          "assets/lim.png",
                          fit: BoxFit
                              .cover, 
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GridBlockPainter extends CustomPainter {
  final double progress;
  GridBlockPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final double w = size.width / 3;
    final double h = size.height / 2;
    final rects = [
      Rect.fromLTWH(0, 0, w, h),
      Rect.fromLTWH(w, 0, w, h),
      Rect.fromLTWH(2 * w, 0, w, h),
      Rect.fromLTWH(0, h, w, h),
      Rect.fromLTWH(w, h, w, h),
      Rect.fromLTWH(2 * w, h, w, h),
    ];

    final colors = [
      const Color(0xFF00E676), // Green
      const Color(0xFF6C5CE7), // Purple
      const Color(0xFFFFD700), // Yellow
      const Color(0xFFFFB84D), // Orange
      const Color(0xFF00D4FF), // Cyan
      const Color(0xFFFF3366), // Pink
    ];

    for (int i = 0; i < rects.length; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(progress)
        ..style = PaintingStyle.fill
        ..strokeWidth = 3;
      canvas.drawRect(rects[i], paint);

      final border = Paint()
        ..color = Colors.black.withOpacity(progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(rects[i], border);
    }
  }

  @override
  bool shouldRepaint(covariant GridBlockPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class MiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width / 3;
    final double h = size.height / 2;

    final rects = [
      Rect.fromLTWH(0, 0, w, h),
      Rect.fromLTWH(w, 0, w, h),
      Rect.fromLTWH(2 * w, 0, w, h),
      Rect.fromLTWH(0, h, w, h),
      Rect.fromLTWH(w, h, w, h),
      Rect.fromLTWH(2 * w, h, w, h),
    ];

    final colors = [
      const Color(0xFF00E676),
      const Color(0xFF6C5CE7),
      const Color(0xFFFFD700),
      const Color(0xFFFFB84D),
      const Color(0xFF00D4FF),
      const Color(0xFFFF3366),
    ];

    for (int i = 0; i < rects.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;
      canvas.drawRect(rects[i], paint);

      final border = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rects[i], border);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
