import 'dart:math';

import 'package:flutter/material.dart';

class LinePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2C2C).withOpacity(0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.butt;

    final random = Random(42);
    final List<Rect> occupiedSpaces = [];
    
    int attempts = 0;
    int linesDrawn = 0;
    int maxLines = 140;
    
    // Generate non-overlapping horizontal and vertical lines
    while (linesDrawn < maxLines && attempts < maxLines * 10) {
      attempts++;
      
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double length = 40 + random.nextDouble() * 60;
      
      bool isHorizontal = random.nextBool();
      
      Rect lineRect;
      Offset start, end;
      
      if (isHorizontal) {
        start = Offset(x, y);
        end = Offset(x + length, y);
        lineRect = Rect.fromLTRB(x - 6, y - 6, x + length + 6, y + 6);
      } else {
        start = Offset(x, y);
        end = Offset(x, y + length);
        lineRect = Rect.fromLTRB(x - 6, y - 6, x + 6, y + length + 6);
      }
      
      // Check if this line overlaps with any existing lines
      bool overlaps = false;
      for (var occupied in occupiedSpaces) {
        if (lineRect.overlaps(occupied)) {
          overlaps = true;
          break;
        }
      }
      
      // If no overlap, draw the line
      if (!overlaps) {
        canvas.drawLine(start, end, paint);
        occupiedSpaces.add(lineRect);
        linesDrawn++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}