import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/screen_transitions/no_transitions_builder.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'colors.dart';

Brightness brightness = Brightness.dark;
MaterialColor primarySwatch =
    createMaterialColor(WitnetPallet.brightCyanOpacity1);
Color primaryColor = WitnetPallet.brightCyanOpacity1;
TextSelectionThemeData textSelectionTheme = TextSelectionThemeData(
  cursorColor: WitnetPallet.brightCyan,
  selectionColor: WitnetPallet.brightCyan,
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
  fillColor: WitnetPallet.darkGrey2,
  filled: true,
  errorStyle: TextStyle(color: WitnetPallet.brightRed),
  helperStyle: TextStyle(color: WitnetPallet.white),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: TextStyle(color: WitnetPallet.mediumGrey),
  labelStyle: TextStyle(color: WitnetPallet.mediumGrey),
  hoverColor: const Color.fromARGB(9, 255, 255, 255),
  focusColor: WitnetPallet.brightCyanOpacity1,
  isDense: true,
  isCollapsed: false,
  contentPadding: EdgeInsets.all(16),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.darkGrey2, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightCyan, width: 2.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.opacityWhite, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(24),
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
        borderRadius: BorderRadius.all(Radius.circular(24))),
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
      foregroundColor: WitnetPallet.black,
      backgroundColor: WitnetPallet.brightCyan,
      disabledForegroundColor:
          Color.fromARGB(102, 164, 212, 204).withOpacity(0.38),
      disabledBackgroundColor:
          Color.fromARGB(102, 164, 212, 204).withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      textStyle: const TextStyle(
        fontFamily: 'Almarai',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: WitnetPallet.black,
      )),
);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
  foregroundColor: WitnetPallet.white,
  disabledForegroundColor: Color.fromARGB(78, 240, 243, 245).withOpacity(0.38),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  side: BorderSide(width: 1, color: WitnetPallet.white),
  padding: const EdgeInsets.all(16),
  textStyle: const TextStyle(
    fontSize: 16,
    fontFamily: 'Almarai',
    fontWeight: FontWeight.bold,
    color: WitnetPallet.white,
  ),
));
CardTheme cardTheme = CardTheme(
  elevation: 5.0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
  color: WitnetPallet.brightCyanOpacity1,
);
IconThemeData iconTheme = IconThemeData(
  color: WitnetPallet.opacityWhite,
  size: 16,
);
ButtonThemeData buttonThemeData = ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)));
IconThemeData primaryIconTheme = IconThemeData(
  color: WitnetPallet.opacityWhite,
  size: 24,
);
CheckboxThemeData checkboxTheme = CheckboxThemeData(
  splashRadius: 0,
  side: WidgetStateBorderSide.resolveWith(
      (_) => const BorderSide(width: 2, color: WitnetPallet.brightCyan)),
  fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
    if (states.contains(WidgetState.selected)) {
      return WitnetPallet.brightCyan;
    }
    return WitnetPallet.transparent;
  }),
  checkColor: WidgetStateProperty.all(WitnetPallet.black),
  overlayColor: WidgetStateProperty.all(WitnetPallet.black),
);
Color getColorPrimary(Set<WidgetState> states) {
  const Set<WidgetState> activeStates = <WidgetState>{WidgetState.selected};
  if (states.any(activeStates.contains)) {
    return WitnetPallet.brightCyan;
  }
  return WitnetPallet.lightGrey;
}

Color getColorSecondary(Set<WidgetState> states) {
  const Set<WidgetState> activeStates = <WidgetState>{WidgetState.selected};
  if (states.any(activeStates.contains)) {
    return WitnetPallet.brightCyanOpacity1;
  }
  return WitnetPallet.opacityWhite;
}

SwitchThemeData switchTheme = SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith(getColorPrimary),
  trackColor: WidgetStateProperty.resolveWith(getColorSecondary),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
  backgroundColor: WitnetPallet.black,
  cancelButtonStyle: textButtonTheme.style,
  confirmButtonStyle: textButtonTheme.style,

  /// day period
  dayPeriodBorderSide: BorderSide(color: WitnetPallet.brightCyan, width: 1),
  dayPeriodColor: stateColor(WitnetPallet.brightCyan, WitnetPallet.black),
  dayPeriodShape: RoundedRectangleBorder(
      side: BorderSide(color: WitnetPallet.brightCyan, width: 5),
      borderRadius: BorderRadius.all(Radius.circular(4))),
  dayPeriodTextColor: stateColor(WitnetPallet.darkGrey, WitnetPallet.white),
  dayPeriodTextStyle: textTheme.bodyMedium,

  /// dial
  dialBackgroundColor: WitnetPallet.transparentGrey,
  dialHandColor: WitnetPallet.brightCyan,
  dialTextColor: stateColor(WitnetPallet.darkGrey, WitnetPallet.white),
  dialTextStyle: textTheme.bodyMedium,
  elevation: 0,
  entryModeIconColor: WitnetPallet.brightCyan,
  helpTextStyle: textTheme.titleLarge,

  /// hour minute
  hourMinuteColor:
      stateColor(WitnetPallet.brightCyanOpacity3, WitnetPallet.transparent),
  hourMinuteShape: RoundedRectangleBorder(
    side: BorderSide(
        color: stateColor(WitnetPallet.brightCyan, WitnetPallet.lightGrey),
        width: 0),
    borderRadius: BorderRadius.all(Radius.circular(4)),
  ),
  hourMinuteTextColor: WitnetPallet.lightGrey,
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
  backgroundColor: WitnetPallet.black,
  elevation: 0,
  shadowColor: WitnetPallet.darkGrey,
  surfaceTintColor: WitnetPallet.black,
  shape: RoundedRectangleBorder(
    side: BorderSide.none,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  ),
  headerBackgroundColor: WitnetPallet.brightCyanOpacity1,
  headerForegroundColor: WitnetPallet.lightGrey,
  headerHelpStyle: textTheme.titleLarge!.copyWith(color: WitnetPallet.white),
  weekdayStyle: TextStyle(color: WitnetPallet.lightGrey),
  dayStyle:
      TextStyle(color: WitnetPallet.lightGrey, fontWeight: FontWeight.bold),
  dayForegroundColor: stateColor(WitnetPallet.darkGrey, WitnetPallet.white),
  dayBackgroundColor:
      stateColor(WitnetPallet.brightCyan, WitnetPallet.transparent),
  dayOverlayColor: stateColor(
      WitnetPallet.brightCyanOpacity2, WitnetPallet.brightCyanOpacity2),
  todayForegroundColor:
      stateColor(WitnetPallet.darkGrey, WitnetPallet.brightCyan),
  todayBackgroundColor: stateColor(WitnetPallet.brightCyan, WitnetPallet.black),
  yearStyle: textTheme.bodyMedium!.copyWith(decoration: TextDecoration.none),
  yearForegroundColor: stateColor(WitnetPallet.white, WitnetPallet.lightGrey),
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
  inactiveTrackColor: WitnetPallet.brightCyanOpacity1,
  overlayColor: WitnetPallet.brightCyanOpacity3,
);

ThemeData darkTheme = ThemeData(
    pageTransitionsTheme: pageTransitionsTheme,
    sliderTheme: sliderTheme,
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
        surface: WitnetPallet.black,
        outline: WitnetPallet.transparent,
        error: WitnetPallet.darkRed));
