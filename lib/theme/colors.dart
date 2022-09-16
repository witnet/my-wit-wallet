import 'package:flutter/material.dart' show Color, MaterialColor;

class WitnetPallet {
  static const lightShade = Color(0xFF34B2B2);
  static const lightAccent = Color(0xFF23A6AC);
  static const main = Color(0xFF0697AA);
  static const darkAccent = Color(0xFF72847E);
  static const darkShade2 = Color(0xFF90C8A0);
  static const darkShade = Color(0xFF7EC091);
  static const darkShade1 = Color(0xFF4C5783);
  static const darkShade3 = Color(0xFF222866);
  static const darkShade4 = Color(0xFF17151E);
  static const darkShade5 = Color(0xFF3763AD);
  static const darkShade6 = Color(0xFFE1DEDF);

  static const lightGrey = Color.fromARGB(255, 193, 196, 198);
  static const darkGrey = Color.fromARGB(255, 50, 50, 50);
  static const white = Color.fromARGB(255, 240, 243, 245);
  static const witnetGreen1 = Color.fromARGB(255, 74, 182, 160);
  static const witnetGreen2 = Color.fromARGB(255, 56, 144, 129);
  static const darkBlue1 = Color.fromARGB(255, 13, 45, 67);
  static const darkBlue2 = Color.fromARGB(255, 2, 29, 48);
  static const opacityWitnetGreen = Color.fromRGBO(54, 140, 125, 0.40);
  static const opacityWhite = Color.fromRGBO(240, 243, 245, 80);
  static const opacityWhite2 = Color.fromRGBO(240, 243, 245, 95);
  static const darkRed = Color.fromARGB(255, 179, 0, 12);
  static const brightRed = Color.fromARGB(255, 255, 65, 78);
  static const darkGreen = Color.fromARGB(255, 54, 140, 83);
  static const brightGreen = Color.fromARGB(255, 54, 140, 83);
}

class BaseColorPallet {
  static const primary = Color(0xFF3763AD);
  static const primaryVariant = Color(0xFF222866);
  static const secondary = Color(0xFF3763AD);
  static const secondaryVariant = Color(0xFF222866);
  static const background = Color(0xFF222866);
  static const surface = Color(0xFF222866);
  static const error = Color(0xFF222866);
  static const onPrimary = Color(0xFF222866);
  static const onSecondary = Color(0xFF222866);
  static const onBackground = Color(0xFF222866);
  static const onSurface = Color(0xFF222866);
  static const onError = Color(0xFF222866);
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
