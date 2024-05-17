import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/screen_transitions/no_transitions_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'colors.dart';

Brightness brightness = Brightness.dark;
MaterialColor primarySwatch =
    createMaterialColor(WitnetPallet.opacityWitnetGreen);
Color primaryColor = WitnetPallet.opacityWitnetGreen;
TextSelectionThemeData textSelectionTheme = TextSelectionThemeData(
  cursorColor: WitnetPallet.witnetGreen1,
  selectionColor: WitnetPallet.witnetGreen1,
);
Brightness primaryColorBrightness = brightness;
TextTheme textTheme = TextTheme(
  displayLarge: TextStyle(
      fontFamily: 'Almarai',
      height: 1.15,
      letterSpacing: 0,
      color: WitnetPallet.opacityWhite,
      fontSize: 24,
      fontWeight: FontWeight.bold),
  displayMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 18,
      fontWeight: FontWeight.bold),
  displaySmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 16,
      fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 24,
      fontWeight: FontWeight.normal),
  headlineSmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  titleLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.opacityWhite,
      fontSize: 18,
      fontWeight: FontWeight.bold),
  titleMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.opacityWhite,
      fontSize: 16,
      fontWeight: FontWeight.bold),
  titleSmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 14,
      fontWeight: FontWeight.bold),
  bodyLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.opacityWhite,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.opacityWhite,
      fontSize: 14,
      fontWeight: FontWeight.normal),
  bodySmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.opacityWhite,
      fontSize: 12,
      fontWeight: FontWeight.normal),
  labelLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.opacityWhite,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  labelMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 16,
      fontWeight: FontWeight.normal),
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
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightRed, width: 1.0, style: BorderStyle.solid),
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
TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: WitnetPallet.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8))),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    textStyle: const TextStyle(
      fontFamily: 'Almarai',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: WitnetPallet.white,
    ),
  ),
);
ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      foregroundColor: WitnetPallet.white,
      backgroundColor: WitnetPallet.opacityWitnetGreen,
      disabledForegroundColor:
          Color.fromARGB(102, 164, 212, 204).withOpacity(0.38),
      disabledBackgroundColor:
          Color.fromARGB(102, 164, 212, 204).withOpacity(0.12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4)), // background color
      textStyle: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: WitnetPallet.white,
      )),
);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
  foregroundColor: WitnetPallet.white,
  disabledForegroundColor: Color.fromARGB(78, 240, 243, 245).withOpacity(0.38),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  side: BorderSide(width: 1, color: WitnetPallet.white),
  padding: const EdgeInsets.all(16),
  textStyle: const TextStyle(
    fontSize: 16,
    fontFamily: 'Almarai',
    color: WitnetPallet.white,
  ),
));
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.opacityWitnetGreen,
);
IconThemeData iconTheme = IconThemeData(
  color: WitnetPallet.opacityWhite,
  size: 16,
);
ButtonThemeData buttonThemeData = ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)));
IconThemeData primaryIconTheme = IconThemeData(
  color: WitnetPallet.opacityWhite,
  size: 24,
);
CheckboxThemeData checkboxTheme = CheckboxThemeData(
  splashRadius: 0,
  side: MaterialStateBorderSide.resolveWith(
      (_) => const BorderSide(width: 2, color: WitnetPallet.witnetGreen1)),
  fillColor: MaterialStateProperty.resolveWith((Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return WitnetPallet.witnetGreen1;
    }
    return WitnetPallet.transparent;
  }),
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
  return WitnetPallet.lightGrey;
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

PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
  builders: kIsWeb
      ? {
          // No animations for every OS if the app running on the web
          for (final platform in TargetPlatform.values)
            platform: const NoTransitionsBuilder(),
        }
      : const {
          // handle other platforms you are targeting
        },
);

TimePickerThemeData timePickerTheme = TimePickerThemeData(
  backgroundColor: WitnetPallet.darkBlue2,
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,

  /// day period
  dayPeriodBorderSide: BorderSide(color: WitnetPallet.witnetGreen1, width: 1),
  dayPeriodColor: stateColor(WitnetPallet.witnetGreen1, WitnetPallet.darkBlue2),
  dayPeriodShape: RoundedRectangleBorder(
      side: BorderSide(color: WitnetPallet.witnetGreen1, width: 5),
      borderRadius: BorderRadius.all(Radius.circular(4))),
  dayPeriodTextColor: stateColor(WitnetPallet.darkGrey, WitnetPallet.white),
  dayPeriodTextStyle: textTheme.bodyMedium,

  /// dial
  dialBackgroundColor: WitnetPallet.transparentGrey,
  dialHandColor: WitnetPallet.witnetGreen1,
  dialTextColor: stateColor(WitnetPallet.darkGrey, WitnetPallet.white),
  dialTextStyle: textTheme.bodyMedium,
  elevation: 0,
  entryModeIconColor: WitnetPallet.witnetGreen1,
  helpTextStyle: textTheme.titleLarge,

  /// hour minute
  hourMinuteColor:
      stateColor(WitnetPallet.opacityWitnetGreen3, WitnetPallet.transparent),
  hourMinuteShape: RoundedRectangleBorder(
    side: BorderSide(
        color: stateColor(WitnetPallet.witnetGreen1, WitnetPallet.lightGrey),
        width: 0),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  hourMinuteTextColor: WitnetPallet.lightGrey,
  hourMinuteTextStyle: textTheme.titleLarge,
  inputDecorationTheme: inputDecorationTheme.copyWith(
    outlineBorder: BorderSide(
      color: stateColor(WitnetPallet.witnetGreen1, WitnetPallet.darkGrey),
    ),
    focusColor: WitnetPallet.witnetGreen1,
    hoverColor: WitnetPallet.opacityWitnetGreen3,
  ),

  padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 15),
  shape: RoundedRectangleBorder(
    side: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
);

DatePickerThemeData datePickerTheme = DatePickerThemeData(
  backgroundColor: WitnetPallet.darkBlue2,
  elevation: 0,
  shadowColor: WitnetPallet.darkGrey,
  surfaceTintColor: WitnetPallet.darkBlue2,
  shape: RoundedRectangleBorder(
    side: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  headerBackgroundColor: WitnetPallet.opacityWitnetGreen,
  headerForegroundColor: WitnetPallet.lightGrey,
  headerHelpStyle: textTheme.titleLarge!.copyWith(color: WitnetPallet.white),
  weekdayStyle: TextStyle(color: WitnetPallet.lightGrey),
  dayStyle:
      TextStyle(color: WitnetPallet.lightGrey, fontWeight: FontWeight.bold),
  dayForegroundColor: stateColor(WitnetPallet.darkGrey, WitnetPallet.white),
  dayBackgroundColor:
      stateColor(WitnetPallet.witnetGreen1, WitnetPallet.transparent),
  dayOverlayColor: stateColor(
      WitnetPallet.opacitywitnetGreen2, WitnetPallet.opacitywitnetGreen2),
  todayForegroundColor:
      stateColor(WitnetPallet.darkGrey, WitnetPallet.witnetGreen1),
  todayBackgroundColor:
      stateColor(WitnetPallet.witnetGreen1, WitnetPallet.darkBlue2),
  yearStyle: textTheme.bodyMedium!.copyWith(decoration: TextDecoration.none),
  yearForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.lightGrey),
  yearBackgroundColor:
      stateColor(WitnetPallet.opacitywitnetGreen2, WitnetPallet.transparent),
  yearOverlayColor: stateColor(
      WitnetPallet.opacitywitnetGreen2, WitnetPallet.opacitywitnetGreen2),
  dividerColor: WitnetPallet.transparent,
  inputDecorationTheme: inputDecorationTheme,
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,
);

ThemeData darkTheme = ThemeData(
    pageTransitionsTheme: pageTransitionsTheme,
    primaryColor: primaryColor,
    switchTheme: switchTheme,
    checkboxTheme: checkboxTheme,
    iconTheme: iconTheme,
    shadowColor: Colors.transparent,
    textSelectionTheme: textSelectionTheme,
    primaryIconTheme: primaryIconTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,
    cardTheme: cardTheme,
    datePickerTheme: datePickerTheme,
    timePickerTheme: timePickerTheme,
    textTheme: textTheme,
    inputDecorationTheme: inputDecorationTheme,
    colorScheme: ColorScheme.dark().copyWith(
        surface: WitnetPallet.darkBlue2,
        outline: WitnetPallet.transparent,
        error: WitnetPallet.darkRed));
