import 'package:flutter/material.dart';
import 'colors.dart';

@immutable
class ExtendedTheme extends ThemeExtension<ExtendedTheme> {
  const ExtendedTheme({
    required this.selectBackgroundColor,
    required this.selectedTextColor,
    required this.dropdownBackgroundColor,
    required this.dropdownTextColor,
  });
  final Color? selectBackgroundColor;
  final Color? selectedTextColor;
  final Color? dropdownBackgroundColor;
  final Color? dropdownTextColor;
  @override
  ExtendedTheme copyWith({
    Color? selectBackgroundColor,
    Color? selectedTextColor,
    Color? dropdownBackgroundColor,
    Color? dropdownTextColor,
  }) {
    return ExtendedTheme(
      selectBackgroundColor: selectBackgroundColor ?? this.selectBackgroundColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      dropdownBackgroundColor: dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
    );
  }
  // Controls how the properties change on theme changes
  @override
  ExtendedTheme lerp(ThemeExtension<ExtendedTheme>? other, double t) {
    if (other is! ExtendedTheme) {
      return this;
    }
    return ExtendedTheme(
      selectBackgroundColor: Color.lerp(selectBackgroundColor, other.selectBackgroundColor, t),
      selectedTextColor: Color.lerp(selectedTextColor, other.selectedTextColor, t),
      dropdownBackgroundColor: Color.lerp(dropdownBackgroundColor, other.dropdownBackgroundColor, t),
      dropdownTextColor: Color.lerp(dropdownTextColor, other.dropdownTextColor, t),
    );
  }
  // the light theme
  static const light = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.darkBlue2,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.white,
    dropdownTextColor: WitnetPallet.darkGrey,
  );
  // the dark theme
  static const dark = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.opacityWitnetGreen,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.opacityWitnetGreen,
    dropdownTextColor: WitnetPallet.white,
  );
}