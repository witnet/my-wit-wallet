import 'package:flutter/material.dart';
import 'colors.dart';

Brightness brightness = Brightness.light;
MaterialColor primarySwatch = createMaterialColor(WitnetPallet.witnetGreen2);
Color primaryColor = WitnetPallet.witnetGreen2;
Brightness primaryColorBrightness = brightness;
TextTheme textTheme = TextTheme(
  headline1: TextStyle(fontFamily: 'Quicksand', color: WitnetPallet.darkGrey, fontSize: 24, fontWeight: FontWeight.bold),
  headline2: TextStyle(fontFamily: 'Quicksand', color: WitnetPallet.darkGrey, fontSize: 24, fontWeight: FontWeight.normal),
  bodyText1: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.darkGrey, fontSize: 16, fontWeight: FontWeight.normal),
  bodyText2: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.darkGrey, fontSize: 14, fontWeight: FontWeight.normal),
  caption: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.darkGrey, fontSize: 12, fontWeight: FontWeight.normal),
  button: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.white, fontSize: 16, fontWeight: FontWeight.normal),
);
InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  fillColor: Color(0xFFFFFFFF),
  filled: true,
  labelStyle: TextStyle(),
  prefixStyle: TextStyle(),
  suffixStyle: TextStyle(),
  errorStyle: TextStyle(backgroundColor: Color(0xFFFFFFFF)),
  helperStyle: TextStyle(backgroundColor: Color(0xFFFFFF00)),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: TextStyle(),
  hoverColor: Color(0xFFFFFFFF),
  focusColor: Color(0xFF41BEA5),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  isDense: false,
  isCollapsed: false,
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: const Color(0x55948C80), width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(7.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: const Color(0x551DA3B2), width: 2.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(7.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: const Color(0xFFF7F7F8), width: 2.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(7.0),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
        color: const Color(0xFFF7F7F8), width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(7.0),
  ),
  alignLabelWithHint: true,
);
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.darkBlue2,
  // shadowColor: Color(0xFF112338),
);
ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(16),
    onSurface: Color.fromARGB(114, 2, 29, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    primary: WitnetPallet.darkBlue2, // background color
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: WitnetPallet.white,
    )
  ),
);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    primary: WitnetPallet.darkBlue2,
    onSurface: Color.fromARGB(114, 2, 29, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(width: 2, color: WitnetPallet.darkBlue2),
    padding: const EdgeInsets.all(16),
    textStyle: const TextStyle(
      fontSize: 16,
      color: WitnetPallet.darkBlue2,
    ),
  )
);
ThemeData lightTheme = ThemeData(
  primaryColor: primaryColor,
  backgroundColor: WitnetPallet.white,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  cardTheme: cardTheme,
  textTheme: textTheme,
  inputDecorationTheme: inputDecorationTheme,
);
