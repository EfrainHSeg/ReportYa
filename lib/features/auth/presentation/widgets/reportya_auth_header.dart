import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/core/theme/app_theme.dart';

class ReportYaAuthHeader extends StatelessWidget {
  const ReportYaAuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      height: 224 + topPadding,
      color: AppColors.amarilloCat,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DiagonalLinesPainter()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPadding + 24, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Row(
                  children: [
                    _FerreyrosBadge(),
                    SizedBox(width: 8),
                    _CatBadge(),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'ReportYa',
                  style: AppTheme.brandTitle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FerreyrosBadge extends StatelessWidget {
  const _FerreyrosBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.naranjaFerreyros,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'Ferreyros',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatBadge extends StatelessWidget {
  const _CatBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.negro,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text(
        'CAT',
        style: TextStyle(
          color: AppColors.amarilloCat,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _DiagonalLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lineasDiag
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    const spacing = 18.0;
    final diagonal = size.width + size.height;

    for (double i = -diagonal; i < diagonal; i += spacing) {
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
