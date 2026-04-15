import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reportya/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textoNegro,
      displayColor: AppColors.textoNegro,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.fondoBlanco,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.amarilloCat,
        secondary: AppColors.naranjaFerreyros,
        surface: AppColors.fondoBlanco,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFondo,
        hintStyle: GoogleFonts.montserrat(
          color: AppColors.textoMuyGris,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.inputBorde,
            width: 1.4,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.inputBorde,
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.naranjaFerreyros,
            width: 1.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.montserrat(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static TextStyle brandTitle({
    double fontSize = 42,
    Color color = AppColors.negro,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.2,
      height: 0.98,
      color: color,
    );
  }
}
