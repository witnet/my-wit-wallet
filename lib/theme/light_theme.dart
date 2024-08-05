import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/screen_transitions/no_transitions_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'colors.dart';

Brightness brightness = Brightness.light;
MaterialColor primarySwatch = createMaterialColor(WitnetPallet.witnetGreen1);
Color primaryColor = WitnetPallet.witnetGreen1;
TextSelectionThemeData textSelectionTheme = TextSelectionThemeData(
  cursorColor: WitnetPallet.witnetGreen1,
  selectionColor: WitnetPallet.witnetGreen1,
);
Brightness primaryColorBrightness = brightness;
TextTheme textTheme = TextTheme(
  displayLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 24,
      fontWeight: FontWeight.bold),
  displayMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 18,
      fontWeight: FontWeight.bold),
  displaySmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 16,
      fontWeight: FontWeight.bold),
  headlineMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.witnetGreen1,
      fontSize: 24,
      fontWeight: FontWeight.normal),
  headlineSmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.witnetGreen1,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  titleLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 18,
      fontWeight: FontWeight.bold),
  titleMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 16,
      fontWeight: FontWeight.bold),
  titleSmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 14,
      fontWeight: FontWeight.bold),
  bodyLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  bodyMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 14,
      fontWeight: FontWeight.normal),
  bodySmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.darkGrey,
      fontSize: 12,
      fontWeight: FontWeight.normal),
  labelLarge: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.white,
      fontSize: 16,
      fontWeight: FontWeight.normal),
  labelMedium: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.witnetGreen1,
      fontSize: 16,
      fontWeight: FontWeight.normal),
);
InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  fillColor: WitnetPallet.white,
  filled: true,
  errorStyle: TextStyle(color: WitnetPallet.darkRed),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.darkRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  helperStyle: TextStyle(color: WitnetPallet.darkGrey),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: TextStyle(),
  hoverColor: WitnetPallet.white,
  focusColor: WitnetPallet.witnetGreen1,
  isDense: false,
  isCollapsed: false,
  contentPadding: EdgeInsets.all(16),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.lightGrey, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.witnetGreen1, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.darkRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.white, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(4),
  ),
  alignLabelWithHint: true,
);
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.darkBlue2,
);
ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      backgroundColor: WitnetPallet.darkBlue2,
      disabledForegroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.38),
      disabledBackgroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.12),
      foregroundColor: WitnetPallet.white,
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4)), // background color
      textStyle: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: WitnetPallet.white,
      )),
);
TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: WitnetPallet.witnetGreen1,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: NoSplash.splashFactory,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8))),
    textStyle: const TextStyle(
      fontFamily: 'Almarai',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: WitnetPallet.witnetGreen1,
    ),
  ),
);
ProgressIndicatorThemeData progressIndicatorTheme = ProgressIndicatorThemeData(
    refreshBackgroundColor: WitnetPallet.opacityWitnetGreen);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
  foregroundColor: WitnetPallet.darkBlue2,
  disabledForegroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.38),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  side: BorderSide(width: 1, color: WitnetPallet.darkBlue2),
  padding: const EdgeInsets.all(16),
  textStyle: const TextStyle(
    fontFamily: 'Almarai',
    fontSize: 16,
    color: WitnetPallet.darkBlue2,
  ),
));
IconThemeData iconTheme = IconThemeData(
  color: WitnetPallet.witnetGreen1,
  size: 16,
);
IconThemeData primaryIconTheme = IconThemeData(
  color: WitnetPallet.witnetGreen1,
  size: 24,
);
CheckboxThemeData checkboxTheme = CheckboxThemeData(
  splashRadius: 0,
  side: WidgetStateBorderSide.resolveWith(
      (_) => const BorderSide(width: 2, color: WitnetPallet.witnetGreen1)),
  fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return WitnetPallet.witnetGreen1;
    }
    return WitnetPallet.transparent;
  }),
  checkColor: WidgetStateProperty.all(WitnetPallet.white),
  overlayColor: WidgetStateProperty.all(WitnetPallet.white),
);

Color getColorPrimary(Set<WidgetState> states) {
  const Set<WidgetState> activeStates = <WidgetState>{WidgetState.selected};
  if (states.any(activeStates.contains)) {
    return Color.fromARGB(126, 193, 196, 198);
  }
  return Color.fromARGB(126, 193, 196, 198);
}

Color getColorSecondary(Set<WidgetState> states) {
  const Set<WidgetState> activeStates = <WidgetState>{WidgetState.selected};
  if (states.any(activeStates.contains)) {
    return WitnetPallet.witnetGreen1;
  }
  return WitnetPallet.lightGrey;
}

SwitchThemeData switchTheme = SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith(getColorPrimary),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  trackColor: WidgetStateProperty.resolveWith(getColorSecondary),
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
          // handel other platforms you are targeting
        },
);

TimePickerThemeData timePickerTheme = TimePickerThemeData(
  backgroundColor: WitnetPallet.white,
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,

  /// day period
  dayPeriodBorderSide: BorderSide(color: WitnetPallet.darkBlue2, width: 1),
  dayPeriodColor: stateColor(WitnetPallet.darkBlue2, WitnetPallet.white),
  dayPeriodShape: RoundedRectangleBorder(
      side: BorderSide(color: WitnetPallet.witnetGreen1, width: 5),
      borderRadius: BorderRadius.all(Radius.circular(4))),
  dayPeriodTextColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  dayPeriodTextStyle: textTheme.bodyMedium,

  /// dial
  dialBackgroundColor: WitnetPallet.transparentGrey,
  dialHandColor: WitnetPallet.witnetGreen1,
  dialTextColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  dialTextStyle: textTheme.bodyMedium,
  elevation: 0,
  entryModeIconColor: WitnetPallet.witnetGreen1,
  helpTextStyle: textTheme.titleLarge,

  /// hour minute
  hourMinuteColor:
      stateColor(WitnetPallet.opacityWitnetGreen3, WitnetPallet.transparent),
  hourMinuteShape: RoundedRectangleBorder(
    side: BorderSide(
        color: stateColor(WitnetPallet.witnetGreen1, WitnetPallet.darkGrey),
        width: 0),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  hourMinuteTextColor: WitnetPallet.darkGrey,
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
  backgroundColor: WitnetPallet.white,
  elevation: 0,
  shadowColor: WitnetPallet.darkGrey,
  surfaceTintColor: WitnetPallet.darkBlue2,
  shape: RoundedRectangleBorder(
    side: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  headerBackgroundColor: WitnetPallet.darkBlue2,
  headerForegroundColor: WitnetPallet.witnetGreen1,
  headerHelpStyle: textTheme.titleLarge!.copyWith(color: WitnetPallet.white),
  weekdayStyle: TextStyle(color: WitnetPallet.darkGrey),
  dayStyle: TextStyle(color: WitnetPallet.white),
  dayForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  dayBackgroundColor:
      stateColor(WitnetPallet.witnetGreen1, WitnetPallet.transparent),
  dayOverlayColor: stateColor(
      WitnetPallet.opacitywitnetGreen2, WitnetPallet.opacitywitnetGreen2),
  todayForegroundColor:
      stateColor(WitnetPallet.white, WitnetPallet.witnetGreen1),
  todayBackgroundColor:
      stateColor(WitnetPallet.witnetGreen1, WitnetPallet.white),
  yearStyle: textTheme.bodyMedium!.copyWith(decoration: TextDecoration.none),
  yearForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  yearBackgroundColor:
      stateColor(WitnetPallet.opacitywitnetGreen2, WitnetPallet.transparent),
  yearOverlayColor: stateColor(
      WitnetPallet.opacitywitnetGreen2, WitnetPallet.opacitywitnetGreen2),
  dividerColor: WitnetPallet.transparent,
  inputDecorationTheme: inputDecorationTheme,
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,
);

ThemeData lightTheme = ThemeData(
    pageTransitionsTheme: pageTransitionsTheme,
    progressIndicatorTheme: progressIndicatorTheme,
    primaryColor: primaryColor,
    switchTheme: switchTheme,
    checkboxTheme: checkboxTheme,
    splashColor: Colors.transparent,
    iconTheme: iconTheme,
    primaryIconTheme: primaryIconTheme,
    textSelectionTheme: textSelectionTheme,
    shadowColor: Colors.transparent,
    elevatedButtonTheme: elevatedButtonTheme,
    textButtonTheme: textButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    cardTheme: cardTheme,
    textTheme: textTheme,
    datePickerTheme: datePickerTheme,
    timePickerTheme: timePickerTheme,
    inputDecorationTheme: inputDecorationTheme,
    colorScheme: ColorScheme.light().copyWith(
        surface: WitnetPallet.white, outline: WitnetPallet.transparent));
