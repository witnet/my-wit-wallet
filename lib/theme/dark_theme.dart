import 'package:flutter/material.dart';
import 'colors.dart';

Brightness brightness = Brightness.dark;
MaterialColor primarySwatch =
    createMaterialColor(WitnetPallet.opacityWitnetGreen);
Color primaryColor = WitnetPallet.opacityWitnetGreen;
TextSelectionThemeData textSelectionTheme =
    TextSelectionThemeData(cursorColor: WitnetPallet.opacityWitnetGreen);
Brightness primaryColorBrightness = brightness;
TextTheme textTheme = TextTheme(
  headline1: TextStyle(
      fontFamily: 'Quicksand',
      color: WitnetPallet.opacityWhite,
      fontSize: 24,
      fontWeight: FontWeight.bold),
  headline2: TextStyle(
      fontFamily: 'Quicksand',
      color: WitnetPallet.white,
      fontSize: 18,
      fontWeight: FontWeight.bold),
  headline3: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.white,
      fontSize: 16,
      fontWeight: FontWeight.bold),
  subtitle1: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.opacityWhite,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  subtitle2: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.white,
      fontSize: 14,
      fontWeight: FontWeight.bold),
  bodyText1: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.opacityWhite,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  bodyText2: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.opacityWhite,
      fontSize: 14,
      fontWeight: FontWeight.normal),
  caption: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.opacityWhite,
      fontSize: 12,
      fontWeight: FontWeight.normal),
  button: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.opacityWhite,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  labelMedium: TextStyle(
      fontFamily: 'NotoSans',
      color: WitnetPallet.white,
      fontSize: 16,
      fontWeight: FontWeight.bold),
);
InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  fillColor: WitnetPallet.darkBlue2,
  filled: true,
  errorStyle: TextStyle(color: WitnetPallet.brightRed),
  helperStyle: TextStyle(color: WitnetPallet.white),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: TextStyle(color: Color.fromARGB(159, 190, 191, 192)),
  labelStyle: TextStyle(color: WitnetPallet.opacityWhite),
  hoverColor: WitnetPallet.darkBlue2,
  focusColor: WitnetPallet.opacityWitnetGreen,
  isDense: false,
  isCollapsed: false,
  contentPadding: EdgeInsets.all(16),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.opacityWhite, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.opacityWitnetGreen,
        width: 1.0,
        style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.opacityWhite, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
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
      color: WitnetPallet.lightGrey,
    ),
    textStyle: TextStyle(color: WitnetPallet.lightGrey));
ButtonThemeData buttonTheme = ButtonThemeData(
  buttonColor: WitnetPallet.opacityWitnetGreen,
);
TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    primary: WitnetPallet.white,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: WitnetPallet.white,
    ),
  ),
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
      )),
);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
  primary: WitnetPallet.white,
  onSurface: Color.fromARGB(78, 240, 243, 245),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  side: BorderSide(width: 1, color: WitnetPallet.white),
  padding: const EdgeInsets.all(16),
  textStyle: const TextStyle(
    fontSize: 16,
    color: WitnetPallet.white,
  ),
));
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.opacityWitnetGreen,
  // shadowColor: Color(0xFF112338),
);
IconThemeData iconTheme = IconThemeData(
  color: WitnetPallet.opacityWhite,
  size: 16,
);
IconThemeData primaryIconTheme = IconThemeData(
  color: WitnetPallet.opacityWhite,
  size: 24,
);
CheckboxThemeData checkboxTheme = CheckboxThemeData(
  splashRadius: 0,
  side: MaterialStateBorderSide.resolveWith(
      (_) => const BorderSide(width: 2, color: WitnetPallet.witnetGreen2)),
  fillColor: MaterialStateProperty.all(WitnetPallet.witnetGreen2),
  checkColor: MaterialStateProperty.all(WitnetPallet.white),
  overlayColor: MaterialStateProperty.all(WitnetPallet.white),
);
Color getColorPrimary(Set<MaterialState> states) {
  const Set<MaterialState> activeStates = <MaterialState>{
    MaterialState.selected
  };
  if (states.any(activeStates.contains)) {
    return WitnetPallet.witnetGreen1;
  }
  return WitnetPallet.opacityWhite2;
}

Color getColorSecondary(Set<MaterialState> states) {
  const Set<MaterialState> activeStates = <MaterialState>{
    MaterialState.selected
  };
  if (states.any(activeStates.contains)) {
    return WitnetPallet.opacityWitnetGreen;
  }
  return WitnetPallet.opacityWhite;
}

SwitchThemeData switchTheme = SwitchThemeData(
  thumbColor: MaterialStateProperty.resolveWith(getColorPrimary),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  trackColor: MaterialStateProperty.resolveWith(getColorSecondary),
  splashRadius: 1,
);
ThemeData darkTheme = ThemeData(
  primaryColor: primaryColor,
  switchTheme: switchTheme,
  backgroundColor: WitnetPallet.darkBlue2,
  checkboxTheme: checkboxTheme,
  iconTheme: iconTheme,
  shadowColor: Colors.transparent,
  textSelectionTheme: textSelectionTheme,
  primaryIconTheme: primaryIconTheme,
  elevatedButtonTheme: elevatedButtonTheme,
  outlinedButtonTheme: outlinedButtonTheme,
  textButtonTheme: textButtonTheme,
  cardTheme: cardTheme,
  textTheme: textTheme,
  inputDecorationTheme: inputDecorationTheme,
);
