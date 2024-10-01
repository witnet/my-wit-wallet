import 'package:flutter/material.dart'
    show Color, MaterialColor, WidgetState, WidgetStateColor;

class WitnetPallet {
  static const black = Color(0xFF1D1D1B);
  static const white = Color(0xFFFFFFFF);
  static const opacityWhite = Color(0xAFFFFFFF);
  static const opacityWhite2 = Color(0xA0FFFFFF);
  static const opacityBlack = Color(0xAF1D1D1B);
  static const opacityBlack2 = Color(0xA01D1D1B);

  static const lighterGrey = Color(0xFFEDECEC);
  static const lightGrey = Color(0xFFBDBDBD);
  static const mediumGrey = Color(0xFF656565);
  static const darkGrey = Color(0xFF424242);
  static const darkerGrey = Color(0xFF292929);

  static const transparent = Color(0x00FFFFFF);
  static const transparentGrey = Color(0x10656565);
  static const transparentGrey2 = Color(0x18656565);
  static const transparentWhite = Color(0x10656565);

  static const brightCyan = Color(0xFF00E2ED);
  static const deepAqua = Color(0xFF0099A1);
  static const brightCyanOpacity1 = Color.fromARGB(163, 0, 225, 237);
  static const brightCyanOpacity2 = Color.fromARGB(82, 0, 225, 237);
  static const brightCyanOpacity3 = Color.fromARGB(26, 0, 225, 237);

  static const darkRed = Color.fromARGB(255, 211, 53, 64);
  static const darkOrange = Color.fromARGB(255, 202, 119, 1);
  static const brightRed = Color.fromARGB(255, 236, 56, 56);
  static const brightOrange = Color(0xFFed9900);
  static const darkGreen = Color.fromARGB(255, 25, 147, 66);
  static const brightGreen = Color.fromARGB(212, 67, 252, 187);
  static const brown = Color.fromARGB(255, 147, 82, 1);
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

WidgetStateColor stateColor(Color selectedColor, Color defaultColor) {
  return WidgetStateColor.resolveWith((states) =>
      states.contains(WidgetState.selected) ? selectedColor : defaultColor);
}
