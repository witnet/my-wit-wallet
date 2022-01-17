
import 'package:flutter/material.dart';

import 'app_themes.dart';
import 'colors.dart';

Brightness brightness = Brightness.dark;
VisualDensity visualDensity = defaultDensity;
MaterialColor primarySwatch = createMaterialColor(WitnetPallet.darkShade);
Color primaryColor = WitnetPallet.darkShade;
Brightness primaryColorBrightness = brightness;

TooltipThemeData tooltipTheme = TooltipThemeData(
    height: 10,
    padding: EdgeInsets.all(5),
    margin: EdgeInsets.all(5),
    verticalOffset: 0.0,
    preferBelow: false,
    decoration: BoxDecoration(color:  WitnetPallet.darkShade6,),
    textStyle: TextStyle(color: WitnetPallet.darkShade6)
);
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
  overline:  TextStyle(fontFamily: 'NotoSans'),
);

ThemeData darkTheme = ThemeData(
  brightness: brightness,
  primaryColor: primaryColor,
  primarySwatch: primarySwatch,
  visualDensity: defaultDensity,

  tooltipTheme: tooltipTheme,
    dialogBackgroundColor:Color(0xFF17151E),
  canvasColor: Color(0xFF17151E),
  shadowColor: Color(0xFF17151E),
  scaffoldBackgroundColor: Color(0xFF17151E),
  bottomAppBarColor: Color(0xFF17151E),
  cardColor: Color(0xFF17151E),
 ///
  ///
  textTheme: textTheme
 //  dividerColor: ,
 //  focusColor: ,
 //  hoverColor: ,
 //  highlightColor: ,
 //  splashColor: ,
 //  splashFactory: ,
 //  selectedRowColor: ,
 //  unselectedWidgetColor: ,
 //  disabledColor: ,

);

/*
primaryColorLight
primaryColorDark


buttonTheme
toggleButtonsTheme
secondaryHeaderColor
backgroundColor
dialogBackgroundColor
indicatorColor
hintColor
errorColor
toggleableActiveColor
fontFamily
- textTheme
primaryTextTheme
inputDecorationTheme
iconTheme
primaryIconTheme
sliderTheme
tabBarTheme
tooltipTheme
cardTheme
chipTheme
platform
materialTapTargetSize
applyElevationOverlayColor

pageTransitionsTheme
appBarTheme
scrollbarTheme
bottomAppBarTheme
colorScheme
dialogTheme
floatingActionButtonTheme
navigationBarTheme
navigationRailTheme
typography
cupertinoOverrideTheme
snackBarTheme
bottomSheetTheme
popupMenuTheme
bannerTheme
dividerTheme

buttonBarTheme

bottomNavigationBarTheme
timePickerTheme
textButtonTheme
elevatedButtonTheme
outlinedButtonTheme
dataTableTheme
checkboxTheme
radioTheme
switchTheme
progressIndicatorTheme
drawerTheme
listTileTheme
androidOverscrollIndicator
 */

