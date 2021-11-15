import 'package:flutter/material.dart';
enum WalletTheme {
  Light,
  Dark,

}

final walletThemeData = {
  WalletTheme.Light: lightTheme,
  WalletTheme.Dark: darkTheme,
};
Widget witnetLogo(ThemeData theme){
  return  (theme.brightness == Brightness.light)
      ? Image(image:AssetImage('assets/img/witnet_logo.png'))
      : Image(image:AssetImage('assets/img/witnet_logo_light.png'));
}
class WalletButtonTheme {
  const WalletButtonTheme({
    required this.backgroundColor,
    required this.highlightColor,
    required this.splashColor,
    required this.elevation,
    required this.highlightElevation,
    required this.shape,
  });
  final Color backgroundColor;
  final Color highlightColor;
  final Color splashColor;
  final double elevation;
  final double highlightElevation;
  final ShapeBorder shape;
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Color(0xFF0094A8),
  accentColor: Color(0xFF11877D),
  backgroundColor: Color(0xFFF7F7F8),
  cardColor: Color(0xFFF9F9F9),
  buttonColor: Color(0xFF4582B9),
  cardTheme: lightCardTheme,
  visualDensity: defaultDensity,
  textTheme: TextTheme(
    headline3: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 45.0,
      // fontWeight: FontWeight.w400,
    ),
    headline1: TextStyle(fontFamily: 'Quicksand'),
    headline2: TextStyle(fontFamily: 'Quicksand'),
    headline4: TextStyle(fontFamily: 'Quicksand', color: Color(0xFFF7F7F8)),
    headline5: TextStyle(fontFamily: 'NotoSans', color: Colors.white),
    headline6: TextStyle(fontFamily: 'NotoSans'),
    subtitle1: TextStyle(fontFamily: 'NotoSans'),
    bodyText1: TextStyle(fontFamily: 'NotoSans'),
    bodyText2: TextStyle(fontFamily: 'NotoSans'),
    subtitle2: TextStyle(fontFamily: 'NotoSans'),
    overline:  TextStyle(fontFamily: 'NotoSans'),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Color(0xFFFFFFFF),
    filled: true,
    labelStyle: TextStyle(),
    prefixStyle: TextStyle(),
    suffixStyle: TextStyle(),
    errorStyle: TextStyle(
      backgroundColor: Color(0xFFFFFFFF)
    ),
    helperStyle: TextStyle(
        backgroundColor: Color(0xFFFFFF00)
    ),
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
          color: const Color(0x55948C80),
          width: 1.0,
          style: BorderStyle.solid
      ),
      borderRadius: BorderRadius.circular(7.0),

    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
          color: const Color(0x551DA3B2),
          width: 2.0,
          style: BorderStyle.solid
      ),
      borderRadius: BorderRadius.circular(7.0),

    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
          color: const Color(0xFFF7F7F8),
          width: 2.0,
          style: BorderStyle.solid
      ),
      borderRadius: BorderRadius.circular(7.0),

    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(
          color: const Color(0xFFF7F7F8),
          width: 1.0,
          style: BorderStyle.solid
      ),
      borderRadius: BorderRadius.circular(7.0),

    ),
    alignLabelWithHint: true,
  ),


);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF17151E),
  visualDensity: defaultDensity,
);

VisualDensity defaultDensity = VisualDensity(horizontal: 0.0, vertical: 0.0);
CardTheme lightCardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  shadowColor: Color(0xFF112338),
);
CardTheme darkCardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  shadowColor: null,
);