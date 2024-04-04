import 'package:flutter/material.dart'
    show Color, MaterialColor, MaterialState, MaterialStateColor;

class WitnetPallet {
  static const black = Color.fromARGB(255, 40, 40, 40);
  static const lightGrey = Color.fromARGB(255, 193, 196, 198);
  static const mediumGrey = Color.fromRGBO(101, 101, 101, 1);
  static const darkGrey = Color.fromARGB(255, 50, 50, 50);
  static const white = Color.fromARGB(255, 240, 243, 245);
  static const witnetGreen1 = Color.fromARGB(255, 80, 186, 177);
  static const darkBlue1 = Color.fromARGB(255, 13, 45, 67);
  static const darkBlue2 = Color.fromARGB(255, 2, 29, 48);
  static const opacityWitnetGreen = Color.fromRGBO(23, 73, 79, 1);
  static const opacitywitnetGreen2 = Color.fromRGBO(65, 190, 165, 0.25);
  static const opacityWitnetGreen3 = Color.fromRGBO(54, 140, 125, 0.16);
  static const opacitywitnetGreen4 = Color.fromRGBO(54, 140, 125, 0.24);
  static const opacityWhite = Color.fromRGBO(240, 243, 245, 80);
  static const opacityWhite2 = Color.fromRGBO(240, 243, 245, 95);
  static const darkRed = Color.fromARGB(255, 179, 0, 12);
  static const darkOrange = Color.fromARGB(255, 179, 104, 0);
  static const brightRed = Color.fromARGB(255, 255, 65, 78);
  static const brightOrange = Color.fromARGB(255, 255, 176, 65);
  static const darkGreen = Color.fromARGB(255, 54, 140, 83);
  static const brightGreen = Color.fromRGBO(74, 182, 161, 1);
  static const transparent = Color.fromARGB(0, 255, 255, 255);
  static const transparentGrey = Color.fromARGB(16, 126, 126, 126);
  static const transparentWhite = Color.fromARGB(16, 255, 255, 255);
  static const brown = Color.fromRGBO(95, 65, 33, 1);
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

MaterialStateColor stateColor(Color selectedColor, Color defaultColor) {
  return MaterialStateColor.resolveWith((states) =>
      states.contains(MaterialState.selected) ? selectedColor : defaultColor);
}
