import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFCF6679);
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color boardBackground = Color(0xFFF5F5F5);
  static const Color boardBackgroundDark = Color(0xFF2A2A3E);
  static const Color cellBorder = Color(0xFFBDBDBD);
  static const Color cellBorderDark = Color(0xFF444466);
  static const Color boxBorder = Color(0xFF333333);
  static const Color boxBorderDark = Color(0xFF666688);
  static const Color selectedCell = Color(0xFFBBDEFB);
  static const Color selectedCellDark = Color(0xFF1A3A5C);
  static const Color highlightedCell = Color(0xFFE3F2FD);
  static const Color highlightedCellDark = Color(0xFF1E2A3A);
  static const Color conflictColor = Color(0xFFE57373);
  static const Color givenNumber = Color(0xFF212121);
  static const Color givenNumberDark = Color(0xFFE0E0E0);
  static const Color userNumber = Color(0xFF1565C0);
  static const Color userNumberDark = Color(0xFF64B5F6);
  static const Color noteText = Color(0xFF757575);
  static const Color noteTextDark = Color(0xFF9E9E9E);
  static const Color hintColor = Color(0xFF4CAF50);
  static const Color victoryGold = Color(0xFFFFD700);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primaryColor,
    scaffoldBackgroundColor: surfaceDark,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
  );
}
