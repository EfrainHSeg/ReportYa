import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashFerreyrosBadge extends StatelessWidget {
  const SplashFerreyrosBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFFF5821F),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              '+',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5821F),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'Ferreyros',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            'CAT',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFFD100),
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
