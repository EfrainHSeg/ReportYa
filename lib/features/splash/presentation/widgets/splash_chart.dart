import 'package:flutter/material.dart';

class SplashChart extends StatelessWidget {
  const SplashChart({
    super.key,
    required this.barProgress,
    required this.baseProgress,
    required this.lineProgress,
    required this.dotProgress,
  });

  final List<double> barProgress;
  final double baseProgress;
  final double lineProgress;
  final List<double> dotProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: CustomPaint(
        painter: _SplashChartPainter(
          barProgress: barProgress,
          baseProgress: baseProgress,
          lineProgress: lineProgress,
          dotProgress: dotProgress,
        ),
      ),
    );
  }
}

class _SplashChartPainter extends CustomPainter {
  const _SplashChartPainter({
    required this.barProgress,
    required this.baseProgress,
    required this.lineProgress,
    required this.dotProgress,
  });

  final List<double> barProgress;
  final double baseProgress;
  final double lineProgress;
  final List<double> dotProgress;

  static const _bars = [
    [130.0, 520.0, 330.0, 185.0],
    [420.0, 310.0, 540.0, 185.0],
    [710.0, 430.0, 420.0, 185.0],
  ];

  static const _points = [
    [222.0, 460.0],
    [512.0, 240.0],
    [800.0, 390.0],
  ];

  static const _baseY = 870.0;
  static const _baseH = 52.0;

  double _x(double value, double width) => value / 1024 * width;
  double _y(double value, double height) => value / 1024 * height;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final blackFill =
        Paint()
          ..color = const Color(0xFF111111)
          ..style = PaintingStyle.fill;

    for (var i = 0; i < _bars.length; i++) {
      final progress = barProgress[i].clamp(0.0, 1.0);
      if (progress <= 0) {
        continue;
      }

      final fullHeight = _y(_bars[i][2], height);
      final baseBottom = _y(_baseY, height);
      final currentHeight = fullHeight * progress;
      final currentY = baseBottom - currentHeight;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            _x(_bars[i][0], width),
            currentY,
            _x(_bars[i][3], width),
            currentHeight,
          ),
          const Radius.circular(4),
        ),
        blackFill,
      );
    }

    if (baseProgress > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            _x(100, width),
            _y(_baseY, height),
            _x(824, width) * baseProgress,
            _y(_baseH, height),
          ),
          const Radius.circular(4),
        ),
        blackFill,
      );
    }

    if (lineProgress <= 0) {
      return;
    }

    final linePaint =
        Paint()
          ..color = const Color(0xFFF5821F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _x(52, width)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final p0 = Offset(_x(_points[0][0], width), _y(_points[0][1], height));
    final p1 = Offset(_x(_points[1][0], width), _y(_points[1][1], height));
    final p2 = Offset(_x(_points[2][0], width), _y(_points[2][1], height));

    final firstSegment = (lineProgress * 2).clamp(0.0, 1.0);
    final secondSegment = ((lineProgress - 0.5) * 2).clamp(0.0, 1.0);

    final path =
        Path()
          ..moveTo(p0.dx, p0.dy)
          ..lineTo(
            p0.dx + (p1.dx - p0.dx) * firstSegment,
            p0.dy + (p1.dy - p0.dy) * firstSegment,
          );

    if (secondSegment > 0) {
      path.lineTo(
        p1.dx + (p2.dx - p1.dx) * secondSegment,
        p1.dy + (p2.dy - p1.dy) * secondSegment,
      );
    }
    canvas.drawPath(path, linePaint);

    for (var i = 0; i < _points.length; i++) {
      final progress = dotProgress[i].clamp(0.0, 1.0);
      if (progress <= 0) {
        continue;
      }

      final cx = _x(_points[i][0], width);
      final cy = _y(_points[i][1], height);

      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(progress, progress);

      if (i == 1) {
        canvas.drawCircle(
          Offset.zero,
          _x(72, width),
          Paint()
            ..color = const Color(0xFFFFD100)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          Offset.zero,
          _x(72, width),
          Paint()
            ..color = const Color(0xFFF5821F)
            ..style = PaintingStyle.stroke
            ..strokeWidth = _x(52, width),
        );
      } else {
        canvas.drawCircle(
          Offset.zero,
          _x(58, width),
          Paint()
            ..color = const Color(0xFFF5821F)
            ..style = PaintingStyle.fill,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SplashChartPainter oldDelegate) {
    return oldDelegate.barProgress != barProgress ||
        oldDelegate.baseProgress != baseProgress ||
        oldDelegate.lineProgress != lineProgress ||
        oldDelegate.dotProgress != dotProgress;
  }
}
