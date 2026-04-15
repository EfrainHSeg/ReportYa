import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_colors.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.inputFondo,
          side: const BorderSide(color: AppColors.inputBorde, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CustomPaint(painter: _GoogleIconPainter()),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continuar con Google',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textoGrisOscuro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final radius = (size.width - stroke) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.15, false, paint);

    paint.color = const Color(0xFFDB4437);
    canvas.drawArc(rect, 1.0, 1.05, false, paint);

    paint.color = const Color(0xFFF4B400);
    canvas.drawArc(rect, 2.1, 1.0, false, paint);

    paint.color = const Color(0xFF0F9D58);
    canvas.drawArc(rect, 3.1, 1.1, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final barY = center.dy;
    final barStartX = center.dx + radius * 0.15;
    final barEndX = size.width - stroke * 0.3;
    canvas.drawLine(
      Offset(barStartX, barY),
      Offset(barEndX, barY),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
