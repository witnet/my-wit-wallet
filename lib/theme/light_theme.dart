import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
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

const TextStyle defaultTextStyle = TextStyle(
  color: WitnetPallet.black,
  fontSize: 14,
  fontWeight: FontWeight.normal,
  fontStyle: FontStyle.normal,
  letterSpacing: 0,
  wordSpacing: 0,
  height: 1.5,
);

final TextStyle p = defaultTextStyle.copyWith(fontFamily: 'Poppins');
final TextStyle bodyThin = p.copyWith(fontWeight: FontWeight.w100);
final TextStyle bodyExtraLight = p.copyWith(fontWeight: FontWeight.w200);
final TextStyle bodyLight = p.copyWith(fontWeight: FontWeight.w300);
final TextStyle bodyRegular = p.copyWith(fontWeight: FontWeight.w400);
final TextStyle bodyMedium = p.copyWith(fontWeight: FontWeight.w500);
final TextStyle bodySemiBold = p.copyWith(fontWeight: FontWeight.w600);
final TextStyle bodyBold = p.copyWith(fontWeight: FontWeight.w700);
final TextStyle bodyExtraBold = p.copyWith(fontWeight: FontWeight.w800);
final TextStyle bodyBlack = p.copyWith(fontWeight: FontWeight.w900);

final TextStyle o = defaultTextStyle.copyWith(fontFamily: 'Outfit');
final TextStyle titleThin = o.copyWith(fontWeight: FontWeight.w100);
final TextStyle titleExtraLight = o.copyWith(fontWeight: FontWeight.w200);
final TextStyle titleLight = o.copyWith(fontWeight: FontWeight.w300);
final TextStyle titleRegular = o.copyWith(fontWeight: FontWeight.w400);
final TextStyle titleMedium = o.copyWith(fontWeight: FontWeight.w500);
final TextStyle titleSemiBold = o.copyWith(fontWeight: FontWeight.w600);
final TextStyle titleBold = o.copyWith(fontWeight: FontWeight.w700);
final TextStyle titleExtraBold = o.copyWith(fontWeight: FontWeight.w800);
final TextStyle titleBlack = o.copyWith(fontWeight: FontWeight.w900);

TextTheme textTheme = TextTheme(
  displayLarge: titleMedium.copyWith(fontSize: 57),
  displayMedium: titleMedium.copyWith(fontSize: 45),
  displaySmall: titleMedium.copyWith(fontSize: 36),
  headlineLarge: titleMedium.copyWith(fontSize: 32),
  headlineMedium: titleMedium.copyWith(fontSize: 28),
  headlineSmall: titleMedium.copyWith(fontSize: 24),
  titleLarge: titleRegular.copyWith(fontSize: 22),
  titleMedium: titleRegular.copyWith(fontSize: 16),
  titleSmall: titleRegular.copyWith(fontSize: 14),
  bodyLarge: bodyRegular.copyWith(fontSize: 16, color: WitnetPallet.mediumGrey),
  bodyMedium:
      bodyRegular.copyWith(fontSize: 14, color: WitnetPallet.mediumGrey),
  bodySmall: bodyRegular.copyWith(fontSize: 12, color: WitnetPallet.mediumGrey),
  labelLarge: bodyMedium.copyWith(fontSize: 14),
  labelMedium: bodyMedium.copyWith(fontSize: 12),
  labelSmall: bodyMedium.copyWith(fontSize: 11),
);

InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
  fillColor: WitnetPallet.white,
  filled: true,
  errorStyle: bodyRegular.copyWith(color: WitnetPallet.darkRed, fontSize: 12),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.darkRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(BORDER_RADIUS),
  ),
  helperStyle: TextStyle(color: WitnetPallet.darkerGrey),
  helperMaxLines: 1,
  errorMaxLines: 1,
  hintStyle: bodyRegular
      .copyWith(fontSize: 16)
      .copyWith(color: bodyRegular.color!.withOpacity(0.5)),
  hoverColor: WitnetPallet.white,
  focusColor: WitnetPallet.brightCyan,
  labelStyle: bodyRegular.copyWith(fontSize: 24),
  isDense: true,
  isCollapsed: false,
  contentPadding: const EdgeInsets.all(16),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.black, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(BORDER_RADIUS),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.brightCyan, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(BORDER_RADIUS),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.darkRed, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(BORDER_RADIUS),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
        color: WitnetPallet.white, width: 1.0, style: BorderStyle.solid),
    borderRadius: BorderRadius.circular(BORDER_RADIUS),
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
  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
  backgroundColor: WitnetPallet.black,
  disabledForegroundColor: WitnetPallet.lightGrey,
  disabledBackgroundColor: WitnetPallet.lighterGrey,
  foregroundColor: WitnetPallet.lighterGrey,
  splashFactory: NoSplash.splashFactory,
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BORDER_RADIUS)), // background color
  textStyle: bodyRegular.copyWith(
    fontSize: 16,
    color: WitnetPallet.white,
  ),
));
TextButtonThemeData textButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: WitnetPallet.black,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashFactory: NoSplash.splashFactory,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(32))),
    textStyle: bodyRegular.copyWith(
      fontSize: 16,
      color: WitnetPallet.black,
    ),
  ),
);

TooltipThemeData tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(BORDER_RADIUS),
      color: WitnetPallet.lighterGrey,
    ),
    margin: EdgeInsets.all(8),
    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
    textStyle: bodyRegular.copyWith(color: WitnetPallet.black, fontSize: 12));

ProgressIndicatorThemeData progressIndicatorTheme = ProgressIndicatorThemeData(
    refreshBackgroundColor: WitnetPallet.brightCyanOpacity1);
OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
  backgroundColor: WitnetPallet.white,
  foregroundColor: WitnetPallet.black,
  disabledForegroundColor: Color.fromARGB(114, 2, 29, 48).withOpacity(0.38),
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BORDER_RADIUS)),
  side: BorderSide(width: 1, color: WitnetPallet.black),
  padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
  textStyle: bodyRegular.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: WitnetPallet.black,
  ),
));
IconThemeData iconTheme = IconThemeData(
  color: WitnetPallet.black,
  size: 16,
);
IconThemeData primaryIconTheme = IconThemeData(
  color: WitnetPallet.black,
  size: 24,
);
CheckboxThemeData checkboxTheme = CheckboxThemeData(
  splashRadius: 0,
  side: WidgetStateBorderSide.resolveWith(
      (_) => const BorderSide(width: 2, color: WitnetPallet.black)),
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
  backgroundColor: WitnetPallet.white,
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
  weekdayStyle: bodyRegular,
  dayStyle: bodyRegular.copyWith(color: WitnetPallet.white),
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
    tooltipTheme: tooltipTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    cardTheme: cardTheme,
    textTheme: textTheme,
    datePickerTheme: datePickerTheme,
    timePickerTheme: timePickerTheme,
    inputDecorationTheme: inputDecorationTheme,
    colorScheme: ColorScheme.light().copyWith(
        surface: WitnetPallet.white, outline: WitnetPallet.transparent));
