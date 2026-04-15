import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_colors.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: AppColors.inputBorde, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o contin\u00faa con',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textoMuyGris,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: AppColors.inputBorde, thickness: 1),
        ),
      ],
    );
  }
}
