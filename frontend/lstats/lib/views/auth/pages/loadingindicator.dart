import 'package:flutter/material.dart';
import 'dart:math' as math;

// class LStatsLoadingIndicator extends StatefulWidget {
//   final Map<String, Color> colors;
  
//   const LStatsLoadingIndicator({
//     super.key,
//     required this.colors,
//   });

//   @override
//   State<LStatsLoadingIndicator> createState() => _LStatsLoadingIndicatorState();
// }

// class _LStatsLoadingIndicatorState extends State<LStatsLoadingIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _rotationController;
//   late AnimationController _pulseController;
//   late AnimationController _textController;
  
//   late Animation<double> _rotationAnimation;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _textOpacityAnimation;

//   @override
//   void initState() {
//     super.initState();
    
//     // Rotation animation for the outer ring
//     _rotationController = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     );
//     _rotationAnimation = Tween<double>(
//       begin: 0,
//       end: 2 * math.pi,
//     ).animate(CurvedAnimation(
//       parent: _rotationController,
//       curve: Curves.linear,
//     ));
    
//     // Pulse animation for the inner elements
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     );
//     _pulseAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));
    
//     // Text fade animation
//     _textController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//     _textOpacityAnimation = Tween<double>(
//       begin: 0.6,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _textController,
//       curve: Curves.easeInOut,
//     ));
    
//     // Start animations
//     _rotationController.repeat();
//     _pulseController.repeat(reverse: true);
//     _textController.repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _rotationController.dispose();
//     _pulseController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Custom animated indicator
//           SizedBox(
//             width: 60,
//             height: 60,
//             child: AnimatedBuilder(
//               animation: Listenable.merge([
//                 _rotationController,
//                 _pulseController,
//               ]),
//               builder: (context, child) {
//                 return CustomPaint(
//                   size: const Size(60, 60),
//                   painter: LStatsLoadingPainter(
//                     rotation: _rotationAnimation.value,
//                     pulse: _pulseAnimation.value,
//                     primaryColor: widget.colors['primary']!,
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 24),
          
//           // Animated text
//           AnimatedBuilder(
//             animation: _textOpacityAnimation,
//             builder: (context, child) {
//               return Opacity(
//                 opacity: _textOpacityAnimation.value,
               
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class LStatsLoadingPainter extends CustomPainter {
//   final double rotation;
//   final double pulse;
//   final Color primaryColor;

//   LStatsLoadingPainter({
//     required this.rotation,
//     required this.pulse,
//     required this.primaryColor,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;

//     // Outer rotating ring
//     final outerPaint = Paint()
//       ..color = primaryColor.withOpacity(0.3)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3
//       ..strokeCap = StrokeCap.round;

//     canvas.save();
//     canvas.translate(center.dx, center.dy);
//     canvas.rotate(rotation);
    
//     // Draw outer ring segments
//     for (int i = 0; i < 8; i++) {
//       final startAngle = (i * math.pi * 2 / 8) - (math.pi / 16);
//       final sweepAngle = math.pi / 12;
      
//       canvas.drawArc(
//         Rect.fromCircle(center: Offset.zero, radius: radius - 8),
//         startAngle,
//         sweepAngle,
//         false,
//         outerPaint,
//       );
//     }
    
//     canvas.restore();

//     // Inner pulsing elements
//     final innerPaint = Paint()
//       ..color = primaryColor
//       ..style = PaintingStyle.fill;

//     // Central dot
//     canvas.drawCircle(
//       center,
//       4 * pulse,
//       innerPaint,
//     );

//     // Orbiting dots
//     for (int i = 0; i < 3; i++) {
//       final angle = (rotation * 1.5) + (i * 2 * math.pi / 3);
//       final dotRadius = 15 + (5 * math.sin(rotation * 3 + i));
//       final dotCenter = Offset(
//         center.dx + dotRadius * math.cos(angle),
//         center.dy + dotRadius * math.sin(angle),
//       );
      
//       canvas.drawCircle(
//         dotCenter,
//         2.5 * (1 / pulse), // Inverse pulse for contrast
//         Paint()
//           ..color = primaryColor.withOpacity(0.7)
//           ..style = PaintingStyle.fill,
//       );
//     }

//     // Stats-like bars animation
//     final barPaint = Paint()
//       ..color = primaryColor.withOpacity(0.6)
//       ..style = PaintingStyle.fill;

//     for (int i = 0; i < 4; i++) {
//       final barHeight = 3 + (8 * math.sin(rotation * 2 + i * math.pi / 2));
//       final barWidth = 2.0;
//       final barX = center.dx - 8 + (i * 5.5);
//       final barY = center.dy + 15;
      
//       canvas.drawRect(
//         Rect.fromLTWH(
//           barX,
//           barY - barHeight,
//           barWidth,
//           barHeight,
//         ),
//         barPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(LStatsLoadingPainter oldDelegate) {
//     return oldDelegate.rotation != rotation ||
//            oldDelegate.pulse != pulse ||
//            oldDelegate.primaryColor != primaryColor;
//   }
// }

class LStatsLoadingIndicator extends StatefulWidget {
  final Map<String, Color> colors;
  final double size;

  const LStatsLoadingIndicator({
    super.key,
    required this.colors,
    this.size = 80,
  });

  @override
  State<LStatsLoadingIndicator> createState() => _LStatsLoadingIndicatorState();
}

class _LStatsLoadingIndicatorState extends State<LStatsLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;

  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _textOpacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _textController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _rotationController,
              _pulseController,
            ]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: LStatsSquarePainter(
                  rotation: _rotationAnimation.value,
                  pulse: _pulseAnimation.value,
                  colors: widget.colors,
                ),
              );
            },
          ),
        ),
       
      ],
    );
  }
}

class LStatsSquarePainter extends CustomPainter {
  final double rotation;
  final double pulse;
  final Map<String, Color> colors;

  LStatsSquarePainter({
    required this.rotation,
    required this.pulse,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final squares = [
      colors['primary'] ?? const Color(0xFFFF6B3D),
      colors['secondary'] ?? const Color(0xFFFFB84D),
      colors['accent'] ?? const Color(0xFFE84855),
      colors['highlight'] ?? const Color(0xFFE94196),
    ];

    // Outer rotating colorful squares
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    for (int i = 0; i < squares.length; i++) {
      final angle = (i * (math.pi / 2));
      final distance = 22.0 * pulse;
      final squareCenter = Offset(
        distance * math.cos(angle),
        distance * math.sin(angle),
      );

      final gradient = RadialGradient(
        colors: [
          squares[i],
          squares[i].withOpacity(0.6),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 15))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final sizeFactor = 8.0 + (2 * math.sin(rotation * 2 + i));
      canvas.save();
      canvas.translate(squareCenter.dx, squareCenter.dy);
      canvas.rotate(rotation + (i * 0.7));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: sizeFactor,
            height: sizeFactor,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
    canvas.restore();

    // Central pulsing square (core)
    final coreGradient = LinearGradient(
      colors: [
        (colors['core'] ?? Colors.black).withOpacity(0.9),
        (colors['core'] ?? Colors.black).withOpacity(0.5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final corePaint = Paint()
      ..shader = coreGradient.createShader(Rect.fromCenter(center: center, width: 15, height: 15))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final coreSize = 10 * pulse;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-rotation);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: coreSize, height: coreSize),
        const Radius.circular(2),
      ),
      corePaint,
    );
    canvas.restore();

    // Subtle corner dots for style
    final dotPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    const offset = 30.0;
    for (var dx in [-offset, offset]) {
      for (var dy in [-offset, offset]) {
        canvas.drawCircle(center.translate(dx, dy), 2.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(LStatsSquarePainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.pulse != pulse ||
        oldDelegate.colors != colors;
  }
}
