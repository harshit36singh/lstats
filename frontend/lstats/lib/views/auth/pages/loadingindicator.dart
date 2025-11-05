import 'package:flutter/material.dart';
import 'dart:math' as math;

class BrutalistLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  
  const BrutalistLoadingIndicator({
    super.key,
    this.size = 60,
    this.color = const Color(0xFFFF6B3D),
  });

  @override
  State<BrutalistLoadingIndicator> createState() => _BrutalistLoadingIndicatorState();
}

class _BrutalistLoadingIndicatorState extends State<BrutalistLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: BrutalistLoadingPainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class BrutalistLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  BrutalistLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw 4 rotating squares
    final squareSize = radius * 0.35;
    final positions = [
      Offset(-radius * 0.4, -radius * 0.4),
      Offset(radius * 0.4, -radius * 0.4),
      Offset(radius * 0.4, radius * 0.4),
      Offset(-radius * 0.4, radius * 0.4),
    ];

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final offset = (progress + i * 0.25) % 1.0;
      final angle = offset * math.pi * 2;
      
      canvas.save();
      canvas.translate(center.dx + positions[i].dx, center.dy + positions[i].dy);
      canvas.rotate(angle);

      // Draw square with border
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: squareSize,
        height: squareSize,
      );

      // Fill
      canvas.drawRect(rect, paint..color = color);
      
      // Border
      canvas.drawRect(
        rect,
        paint
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      canvas.restore();
    }

    // Draw center circle with rotation indicator
    final centerCirclePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.2, centerCirclePaint);

    // Draw rotating line inside center circle
    final lineAngle = progress * math.pi * 2;
    final lineLength = radius * 0.15;
    final lineEnd = Offset(
      center.dx + math.cos(lineAngle) * lineLength,
      center.dy + math.sin(lineAngle) * lineLength,
    );

    canvas.drawLine(
      center,
      lineEnd,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(BrutalistLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// Alternative: Simple blocks loading
class BlocksLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  
  const BlocksLoadingIndicator({
    super.key,
    this.size = 80,
    this.color = const Color(0xFFFF6B3D),
  });

  @override
  State<BlocksLoadingIndicator> createState() => _BlocksLoadingIndicatorState();
}

class _BlocksLoadingIndicatorState extends State<BlocksLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size / 2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.15;
                final value = (_controller.value - delay).clamp(0.0, 1.0);
                final height = widget.size / 6 + 
                    (widget.size / 3) * math.sin(value * math.pi);
                
                return Container(
                  width: widget.size / 5,
                  height: height,
                  decoration: BoxDecoration(
                    color: widget.color,
                    border: Border.all(color: Colors.black, width: 2.5),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

// Alternative: Minimal spinner
class MinimalSpinner extends StatefulWidget {
  final double size;
  final Color color;
  
  const MinimalSpinner({
    super.key,
    this.size = 50,
    this.color = const Color(0xFFFF6B3D),
  });

  @override
  State<MinimalSpinner> createState() => _MinimalSpinnerState();
}

class _MinimalSpinnerState extends State<MinimalSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.size / 4),
                  bottomRight: Radius.circular(widget.size / 4),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Full-screen loading overlay
class BrutalistLoadingOverlay extends StatelessWidget {
  final String? message;
  final Color backgroundColor;
  final Color accentColor;

  const BrutalistLoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor = Colors.white,
    this.accentColor = const Color(0xFFFF6B3D),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BrutalistLoadingIndicator(
              size: 80,
              color: accentColor,
            ),
            if (message != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 3),
                ),
                child: Text(
                  message!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Example usage widget
class LoadingExampleScreen extends StatelessWidget {
  const LoadingExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B3D),
        title: const Text(
          'LOADING INDICATORS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  'BRUTALIST LOADER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                const BrutalistLoadingIndicator(
                  size: 80,
                  color: Color(0xFFFF6B3D),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'BLOCKS LOADER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                const BlocksLoadingIndicator(
                  size: 80,
                  color: Color(0xFF6BCF7F),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'MINIMAL SPINNER',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                const MinimalSpinner(
                  size: 60,
                  color: Color(0xFFE84855),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Dialog(
                    backgroundColor: Colors.transparent,
                    child: BrutalistLoadingOverlay(
                      message: 'LOADING DATA...',
                      backgroundColor: Colors.white,
                      accentColor: Color(0xFFFF6B3D),
                    ),
                  ),
                );
                
                // Simulate loading
                Future.delayed(const Duration(seconds: 3), () {
                  Navigator.of(context).pop();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: const Text(
                'SHOW OVERLAY',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}