import 'package:flutter/material.dart' show Color, MaterialColor;

class WitnetPallet {
  static const lightGrey = Color.fromARGB(255, 193, 196, 198);
  static const darkGrey = Color.fromARGB(255, 50, 50, 50);
  static const white = Color.fromARGB(255, 240, 243, 245);
  static const witnetGreen1 = Color.fromARGB(255, 74, 182, 160);
  static const witnetGreen2 = Color.fromARGB(255, 56, 144, 129);
  static const darkBlue1 = Color.fromARGB(255, 13, 45, 67);
  static const darkBlue2 = Color.fromARGB(255, 2, 29, 48);
  static const opacityWitnetGreen = Color.fromRGBO(23, 73, 79, 1);
  static const opacityWhite = Color.fromRGBO(240, 243, 245, 80);
  static const opacityWhite2 = Color.fromRGBO(240, 243, 245, 95);
  static const darkRed = Color.fromARGB(255, 179, 0, 12);
  static const brightRed = Color.fromARGB(255, 255, 65, 78);
  static const darkGreen = Color.fromARGB(255, 54, 140, 83);
  static const brightGreen = Color.fromARGB(255, 54, 140, 83);
  static const transparent = Color.fromARGB(0, 255, 255, 255);
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
