import 'package:flutter/material.dart';
import 'colors.dart';

Brightness brightness = Brightness.dark;
MaterialColor primarySwatch =
    createMaterialColor(WitnetPallet.opacityWitnetGreen);
Color primaryColor = WitnetPallet.opacityWitnetGreen;
Brightness primaryColorBrightness = brightness;
TextTheme textTheme = TextTheme(
  headline3: TextStyle(
    fontFamily: 'OpenSans',
    fontSize: 45.0,
    fontWeight: FontWeight.w100,
  ),
  headline1: TextStyle(fontFamily: 'Quicksand'),
  headline2: TextStyle(fontFamily: 'Quicksand'),
  headline4: TextStyle(fontFamily: 'Quicksand'),
  headline5: TextStyle(fontFamily: 'NotoSans'),
  headline6: TextStyle(fontFamily: 'NotoSans'),
  subtitle1: TextStyle(fontFamily: 'NotoSans'),
  bodyText1: TextStyle(fontFamily: 'NotoSans'),
  bodyText2: TextStyle(fontFamily: 'NotoSans'),
  subtitle2: TextStyle(fontFamily: 'NotoSans'),
  overline: TextStyle(fontFamily: 'NotoSans'),
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
TooltipThemeData tooltipTheme = TooltipThemeData(
    height: 10,
    padding: EdgeInsets.all(5),
    margin: EdgeInsets.all(5),
    verticalOffset: 0.0,
    preferBelow: false,
    decoration: BoxDecoration(
      color: WitnetPallet.darkShade6,
    ),
    textStyle: TextStyle(color: WitnetPallet.darkShade6));
ButtonThemeData buttonTheme = ButtonThemeData(
  buttonColor: WitnetPallet.opacityWitnetGreen,
);
ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(16),
    onSurface: Color.fromARGB(102, 164, 212, 204),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    primary: WitnetPallet.opacityWitnetGreen, // background color
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: WitnetPallet.white,
    )
  ),
);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    primary: WitnetPallet.white,
    onSurface: Color.fromARGB(78, 240, 243, 245),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(width: 2, color: WitnetPallet.white),
    padding: const EdgeInsets.all(16),
    textStyle: const TextStyle(
      fontSize: 16,
      color: WitnetPallet.white,
    ),
  )
);
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.opacityWitnetGreen,
  // shadowColor: Color(0xFF112338),
);
ThemeData darkTheme = ThemeData(
  primaryColor: primaryColor,
  backgroundColor: WitnetPallet.darkBlue2,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  cardTheme: cardTheme,
  textTheme: textTheme,
  inputDecorationTheme: inputDecorationTheme,
);
