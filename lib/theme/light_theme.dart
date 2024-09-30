import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/screen_transitions/no_transitions_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'colors.dart';

Brightness brightness = Brightness.light;
MaterialColor primarySwatch = createMaterialColor(WitnetPallet.brightCyan);
Color primaryColor = WitnetPallet.brightCyan;
TextSelectionThemeData textSelectionTheme = TextSelectionThemeData(
  cursorColor: WitnetPallet.brightCyan,
  selectionColor: WitnetPallet.brightCyan,
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
      color: WitnetPallet.black,
      fontSize: 24,
      fontWeight: FontWeight.normal),
  headlineSmall: TextStyle(
      fontFamily: 'Almarai',
      letterSpacing: 0,
      height: 1.15,
      color: WitnetPallet.deepAqua,
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
      color: WitnetPallet.deepAqua,
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
    borderRadius: BorderRadius.circular(24),
  ),
  helperStyle: TextStyle(color: WitnetPallet.darkerGrey),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: TextStyle(),
  hoverColor: WitnetPallet.white,
  focusColor: WitnetPallet.brightCyan,
  isDense: true,
  isCollapsed: false,
  contentPadding: EdgeInsets.all(16),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.black, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightCyan, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.darkRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.white, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  alignLabelWithHint: true,
);
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.black,
);
ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      backgroundColor: WitnetPallet.black,
      disabledForegroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.38),
      disabledBackgroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.12),
      foregroundColor: WitnetPallet.lighterGrey,
      splashFactory: NoSplash.splashFactory,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)), // background color
      textStyle: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: WitnetPallet.black,
      )),
);
TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: WitnetPallet.black,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: NoSplash.splashFactory,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24))),
    textStyle: const TextStyle(
      fontFamily: 'Almarai',
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: WitnetPallet.black,
    ),
  ),
);
ProgressIndicatorThemeData progressIndicatorTheme = ProgressIndicatorThemeData(
    refreshBackgroundColor: WitnetPallet.brightCyanOpacity1);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
  foregroundColor: WitnetPallet.black,
  disabledForegroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.38),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  side: BorderSide(width: 1, color: WitnetPallet.black),
  padding: const EdgeInsets.all(16),
  textStyle: const TextStyle(
    fontFamily: 'Almarai',
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: WitnetPallet.black,
  ),
));
IconThemeData iconTheme = IconThemeData(
  color: WitnetPallet.deepAqua,
  size: 16,
);
IconThemeData primaryIconTheme = IconThemeData(
  color: WitnetPallet.deepAqua,
  size: 24,
);
CheckboxThemeData checkboxTheme = CheckboxThemeData(
  splashRadius: 0,
  side: WidgetStateBorderSide.resolveWith(
      (_) => const BorderSide(width: 2, color: WitnetPallet.deepAqua)),
  fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return WitnetPallet.deepAqua;
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
    return WitnetPallet.brightCyan;
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
  backgroundColor: const Color.fromARGB(255, 125, 80, 80),
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,

  /// day period
  dayPeriodBorderSide: BorderSide(color: WitnetPallet.black, width: 1),
  dayPeriodColor: stateColor(WitnetPallet.black, WitnetPallet.white),
  dayPeriodShape: RoundedRectangleBorder(
      side: BorderSide(color: WitnetPallet.brightCyan, width: 5),
      borderRadius: BorderRadius.all(Radius.circular(4))),
  dayPeriodTextColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  dayPeriodTextStyle: textTheme.bodyMedium,

  /// dial
  dialBackgroundColor: WitnetPallet.transparentGrey,
  dialHandColor: WitnetPallet.brightCyan,
  dialTextColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  dialTextStyle: textTheme.bodyMedium,
  elevation: 0,
  entryModeIconColor: WitnetPallet.brightCyan,
  helpTextStyle: textTheme.titleLarge,

  /// hour minute
  hourMinuteColor:
      stateColor(WitnetPallet.brightCyanOpacity3, WitnetPallet.transparent),
  hourMinuteShape: RoundedRectangleBorder(
    side: BorderSide(
        color: stateColor(WitnetPallet.brightCyan, WitnetPallet.darkGrey),
        width: 0),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  hourMinuteTextColor: WitnetPallet.darkGrey,
  hourMinuteTextStyle: textTheme.titleLarge,
  inputDecorationTheme: inputDecorationTheme.copyWith(
    outlineBorder: BorderSide(
      color: stateColor(WitnetPallet.brightCyan, WitnetPallet.darkGrey),
    ),
    focusColor: WitnetPallet.brightCyan,
    hoverColor: WitnetPallet.brightCyanOpacity3,
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
  surfaceTintColor: WitnetPallet.black,
  shape: RoundedRectangleBorder(
    side: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  headerBackgroundColor: WitnetPallet.black,
  headerForegroundColor: WitnetPallet.brightCyan,
  headerHelpStyle: textTheme.titleLarge!.copyWith(color: WitnetPallet.white),
  weekdayStyle: TextStyle(color: WitnetPallet.darkGrey),
  dayStyle: TextStyle(color: WitnetPallet.white),
  dayForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  dayBackgroundColor:
      stateColor(WitnetPallet.brightCyan, WitnetPallet.transparent),
  dayOverlayColor: stateColor(
      WitnetPallet.brightCyanOpacity2, WitnetPallet.brightCyanOpacity2),
  todayForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.brightCyan),
  todayBackgroundColor: stateColor(WitnetPallet.brightCyan, WitnetPallet.white),
  yearStyle: textTheme.bodyMedium!.copyWith(decoration: TextDecoration.none),
  yearForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.darkGrey),
  yearBackgroundColor:
      stateColor(WitnetPallet.brightCyanOpacity2, WitnetPallet.transparent),
  yearOverlayColor: stateColor(
      WitnetPallet.brightCyanOpacity2, WitnetPallet.brightCyanOpacity2),
  dividerColor: WitnetPallet.transparent,
  inputDecorationTheme: inputDecorationTheme,
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,
);
SliderThemeData sliderTheme = SliderThemeData(
  showValueIndicator: ShowValueIndicator.always,
  valueIndicatorColor: WitnetPallet.brightCyan,
  thumbColor: WitnetPallet.brightCyan,
  activeTrackColor: WitnetPallet.brightCyan,
  inactiveTrackColor: WitnetPallet.lightGrey,
  overlayColor: WitnetPallet.brightCyanOpacity3,
);

ThemeData lightTheme = ThemeData(
    pageTransitionsTheme: pageTransitionsTheme,
    sliderTheme: sliderTheme,
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
