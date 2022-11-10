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
    required this.walletListBackgroundColor,
    required this.walletActiveItemBackgroundColor,
    required this.walletActiveItemBorderColor,
    required this.walletItemBorderColor,
    required this.inputIconColor,
  });
  final Color? selectBackgroundColor;
  final Color? selectedTextColor;
  final Color? dropdownBackgroundColor;
  final Color? dropdownTextColor;
  final Color? headerTextColor;
  final Color? headerActiveTextColor;
  final Color? headerBackgroundColor;
  final Color? walletListBackgroundColor;
  final Color? walletActiveItemBorderColor;
  final Color? walletActiveItemBackgroundColor;
  final Color? walletItemBorderColor;
  final Color? inputIconColor;
  @override
  ExtendedTheme copyWith(
      {Color? selectBackgroundColor,
      Color? selectedTextColor,
      Color? dropdownBackgroundColor,
      Color? dropdownTextColor,
      Color? walletListBackgroundColor,
      Color? walletActiveItemBorderColor,
      Color? walletItemBorderColor,
      Color? inputIconColor,
      Color? walletActiveItemBackgroundColor}) {
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
      walletListBackgroundColor:
          walletListBackgroundColor ?? this.walletListBackgroundColor,
      walletActiveItemBackgroundColor: walletActiveItemBackgroundColor ??
          this.walletActiveItemBackgroundColor,
      walletActiveItemBorderColor:
          walletActiveItemBorderColor ?? this.walletActiveItemBorderColor,
      walletItemBorderColor:
          walletItemBorderColor ?? this.walletItemBorderColor,
      inputIconColor: inputIconColor ?? this.inputIconColor,
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
      walletListBackgroundColor: Color.lerp(
          walletListBackgroundColor, other.walletListBackgroundColor, t),
      walletActiveItemBackgroundColor: Color.lerp(
          walletActiveItemBackgroundColor,
          other.walletActiveItemBackgroundColor,
          t),
      walletActiveItemBorderColor: Color.lerp(
          walletActiveItemBorderColor, other.walletActiveItemBorderColor, t),
      walletItemBorderColor:
          Color.lerp(walletItemBorderColor, other.walletItemBorderColor, t),
      inputIconColor: Color.lerp(inputIconColor, other.inputIconColor, t),
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
    walletListBackgroundColor: WitnetPallet.darkBlue2,
    walletActiveItemBackgroundColor: WitnetPallet.opacityWitnetGreen2,
    walletActiveItemBorderColor: WitnetPallet.witnetGreen3,
    walletItemBorderColor: WitnetPallet.lightGrey,
    inputIconColor: WitnetPallet.lightGrey,
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
      walletListBackgroundColor: WitnetPallet.opacityWitnetGreen,
      walletActiveItemBackgroundColor: WitnetPallet.opacityWitnetGreen3,
      walletActiveItemBorderColor: WitnetPallet.witnetGreen2,
      walletItemBorderColor: WitnetPallet.opacityWhite2,
      inputIconColor: WitnetPallet.opacityWhite2);
}
