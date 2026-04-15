import 'package:flutter/material.dart';

class SplashLoadingDots extends StatelessWidget {
  const SplashLoadingDots({
    super.key,
    required this.pulse,
  });

  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isCenter = index == 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: isCenter ? pulse : 1.0,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCenter
                    ? const Color(0xFFF5821F)
                    : const Color(0xFF111111).withValues(alpha: 0.2),
              ),
            ),
          ),
        );
      }),
    );
  }
}
