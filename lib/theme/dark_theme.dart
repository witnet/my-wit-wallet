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
  headline1: TextStyle(fontFamily: 'Quicksand', color: WitnetPallet.opacityWhite, fontSize: 24, fontWeight: FontWeight.bold),
  headline2: TextStyle(fontFamily: 'Quicksand', color: WitnetPallet.opacityWhite, fontSize: 24, fontWeight: FontWeight.normal),
  subtitle1: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.opacityWhite, fontSize: 16, fontWeight: FontWeight.normal),
  bodyText1: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.opacityWhite, fontSize: 16, fontWeight: FontWeight.normal),
  bodyText2: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.opacityWhite, fontSize: 14, fontWeight: FontWeight.normal),
  caption: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.opacityWhite, fontSize: 12, fontWeight: FontWeight.normal),
  button: TextStyle(fontFamily: 'NotoSans', color: WitnetPallet.opacityWhite, fontSize: 16, fontWeight: FontWeight.normal),
    labelMedium: TextStyle(
    fontFamily: 'NotoSans',
    color: WitnetPallet.opacityWitnetGreen,
    fontSize: 16,
    fontWeight: FontWeight.normal
  )
);
InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  fillColor: WitnetPallet.darkBlue2,
  filled: true,
  errorStyle: TextStyle(backgroundColor: WitnetPallet.brightRed),
  helperStyle: TextStyle(backgroundColor: WitnetPallet.opacityWhite),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: TextStyle(color: WitnetPallet.opacityWhite),
  labelStyle: TextStyle(color: WitnetPallet.opacityWhite),
  hoverColor: WitnetPallet.darkBlue2,
  focusColor: WitnetPallet.opacityWitnetGreen,
  isDense: false,
  isCollapsed: false,
  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.opacityWhite, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.opacityWitnetGreen, width: 1.0, style: BorderStyle.solid),
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
    (_) => const BorderSide(width: 2, color: WitnetPallet.opacityWitnetGreen)),
  fillColor: MaterialStateProperty.all(WitnetPallet.opacityWitnetGreen),
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
  cardTheme: cardTheme,
  textTheme: textTheme,
  inputDecorationTheme: inputDecorationTheme,
);
