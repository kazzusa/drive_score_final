import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ScoreMeter extends StatelessWidget {
  final int score;
  final double size;

  const ScoreMeter({
    super.key,
    required this.score,
    this.size = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(size, size * 0.6),
            painter: _MeterPainter(score: score),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: size * 0.24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeterPainter extends CustomPainter {
  final int score;

  _MeterPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final radius = size.width * 0.41;
    const strokeWidth = 14.0;

    final trackPaint = Paint()
      ..color = const Color(0xFF1E2A38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppColors.scoreColor(score)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = pi;
    const sweepFull = pi;
    final progress = score.clamp(0, 100) / 100.0;
    final sweepFill = sweepFull * progress;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    // Fill
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        startAngle,
        sweepFill,
        false,
        fillPaint,
      );

      // Dot at tip
      final dotAngle = startAngle + sweepFill;
      final dx = cx + radius * cos(dotAngle);
      final dy = cy + radius * sin(dotAngle);
      final dotPaint = Paint()
        ..color = AppColors.scoreColor(score)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dx, dy), 8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_MeterPainter old) => old.score != score;
}
