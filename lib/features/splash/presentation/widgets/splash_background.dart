import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: Color(0xFFFFD100)),
        ),
        Positioned.fill(
          child: CustomPaint(painter: _DiagonalPatternPainter()),
        ),
        Positioned(
          top: -70,
          right: -60,
          child: _DecorativeCircle(size: 220, opacity: 0.15),
        ),
        Positioned(
          top: -25,
          right: -20,
          child: _DecorativeCircle(size: 135, opacity: 0.10),
        ),
        Positioned(
          bottom: -70,
          left: -50,
          child: _DecorativeCircle(size: 180, opacity: 0.06),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({
    required this.size,
    required this.opacity,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF5821F).withValues(alpha: opacity),
          width: 2,
        ),
      ),
    );
  }
}

class _DiagonalPatternPainter extends CustomPainter {
  const _DiagonalPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0x1AFFFFFF)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

    const spacing = 18.0;
    final total = size.width + size.height;
    for (double i = -total; i < total; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
