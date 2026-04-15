import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashBrandWord extends StatelessWidget {
  const SplashBrandWord({
    super.key,
    required this.progress,
  });

  final List<double> progress;

  static const _brand = 'ReportYa';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_brand.length, (index) {
        final value = progress[index].clamp(0.0, 1.0);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: Text(
              _brand[index],
              style: GoogleFonts.syne(
                fontSize: 42,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
                height: 0.98,
                letterSpacing: -1.1,
              ),
            ),
          ),
        );
      }),
    );
  }
}
