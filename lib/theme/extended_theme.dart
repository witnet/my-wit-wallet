import 'package:flutter/material.dart';
import 'colors.dart';

@immutable
class ExtendedTheme extends ThemeExtension<ExtendedTheme> {
  const ExtendedTheme({
    required this.selectBackgroundColor,
    required this.selectedTextColor,
    required this.dropdownBackgroundColor,
    required this.dropdownTextColor,
    required this.headerBackgroundColor,
    required this.headerTextColor,
    required this.headerActiveTextColor,
  });
  final Color? selectBackgroundColor;
  final Color? selectedTextColor;
  final Color? dropdownBackgroundColor;
  final Color? dropdownTextColor;
  final Color? headerBackgroundColor;
  final Color? headerTextColor;
  final Color? headerActiveTextColor;
  @override
  ExtendedTheme copyWith({
    Color? selectBackgroundColor,
    Color? selectedTextColor,
    Color? dropdownBackgroundColor,
    Color? dropdownTextColor,
  }) {
    return ExtendedTheme(
      selectBackgroundColor:
          selectBackgroundColor ?? this.selectBackgroundColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      dropdownBackgroundColor:
          dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      headerActiveTextColor:
          headerActiveTextColor ?? this.headerActiveTextColor,
    );
  }

  // Controls how the properties change on theme changes
  @override
  ExtendedTheme lerp(ThemeExtension<ExtendedTheme>? other, double t) {
    if (other is! ExtendedTheme) {
      return this;
    }
    return ExtendedTheme(
      selectBackgroundColor:
          Color.lerp(selectBackgroundColor, other.selectBackgroundColor, t),
      selectedTextColor:
          Color.lerp(selectedTextColor, other.selectedTextColor, t),
      dropdownBackgroundColor:
          Color.lerp(dropdownBackgroundColor, other.dropdownBackgroundColor, t),
      dropdownTextColor:
          Color.lerp(dropdownTextColor, other.dropdownTextColor, t),
      headerBackgroundColor:
          Color.lerp(headerBackgroundColor, other.dropdownTextColor, t),
      headerTextColor: Color.lerp(headerTextColor, other.dropdownTextColor, t),
      headerActiveTextColor:
          Color.lerp(headerActiveTextColor, other.dropdownTextColor, t),
    );
  }

  // the light theme
  static const light = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.darkBlue2,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.white,
    dropdownTextColor: WitnetPallet.darkGrey,
    headerActiveTextColor: WitnetPallet.witnetGreen2,
    headerTextColor: WitnetPallet.witnetGreen2,
    headerBackgroundColor: WitnetPallet.darkBlue2,
  );
  // the dark theme
  static const dark = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.opacityWitnetGreen,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.opacityWitnetGreen,
    dropdownTextColor: WitnetPallet.white,
    headerActiveTextColor: WitnetPallet.white,
    headerTextColor: WitnetPallet.white,
    headerBackgroundColor: WitnetPallet.opacityWitnetGreen,
  );
}
