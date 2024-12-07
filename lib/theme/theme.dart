import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension TextStyleColor on TextStyle {
  TextStyle dark() {
    return copyWith(color: Colors.white);
  }
}

class AppTheme {
  static ThemeData lightTheme = FlexThemeData.light(
    scheme: FlexScheme.deepPurple,
    useMaterial3: false,
    subThemesData: const FlexSubThemesData(
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 4.0,
      inputDecoratorFocusedHasBorder: true,
      inputDecoratorUnfocusedHasBorder: true,
    ),
    blendLevel: 14,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.cabin().fontFamily,
    textTheme: GoogleFonts.cabinTextTheme().copyWith(
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
    ),
    typography: Typography.material2021(platform: defaultTargetPlatform),
  );

  static ThemeData darkTheme = FlexThemeData.dark(
    scheme: FlexScheme.deepPurple,
    useMaterial3: false,
    subThemesData: const FlexSubThemesData(
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorRadius: 4.0,
      inputDecoratorFocusedHasBorder: true,
      inputDecoratorUnfocusedHasBorder: true,
    ),
    blendLevel: 14,
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    fontFamily: GoogleFonts.cabin().fontFamily,
    textTheme: GoogleFonts.cabinTextTheme().copyWith(
      headlineLarge: headlineLarge.dark(),
      headlineMedium: headlineMedium.dark(),
      headlineSmall: headlineSmall.dark(),
      bodyLarge: bodyLarge.dark(),
      bodyMedium: bodyMedium.dark(),
      bodySmall: bodySmall.dark(),
    ),
    typography: Typography.material2021(platform: defaultTargetPlatform),
  );

  static final headlineLarge = GoogleFonts.cabin(
    fontSize: 34,
    color: Colors.black,
  );
  static final headlineMedium = GoogleFonts.cabin(
    fontSize: 28,
    color: Colors.black,
  );
  static final headlineSmall = GoogleFonts.cabin(
    fontSize: 22,
    color: Colors.black,
  );
  static final bodyLarge = GoogleFonts.cabin(
    fontSize: 17,
    color: Colors.black,
  );
  static final bodyMedium = GoogleFonts.cabin(
    fontSize: 15,
    color: Colors.black,
  );
  static final bodySmall = GoogleFonts.cabin(
    fontSize: 13,
    color: Colors.black,
  );
}
