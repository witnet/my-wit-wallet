import 'package:flutter/material.dart';
import 'colors.dart';

@immutable
class ExtendedTheme extends ThemeExtension<ExtendedTheme> {
  const ExtendedTheme({
    required this.selectBackgroundColor,
    required this.selectedTextColor,
    required this.dropdownBackgroundColor,
    required this.dropdownTextColor,
    required this.headerDashboardActiveButton,
    required this.headerBackgroundColor,
    required this.headerTextColor,
    required this.headerActiveTextColor,
    required this.walletListBackgroundColor,
    required this.walletActiveItemBackgroundColor,
    required this.walletActiveItemBorderColor,
    required this.walletItemBorderColor,
    required this.inputIconColor,
    required this.txBorderColor,
    required this.txValuePositiveColor,
    required this.txValueNegativeColor,
    required this.stepBarActiveColor,
    required this.stepBarColor,
    required this.dialogBackground,
    required this.monoSmallText,
    required this.monoRegularText,
    required this.monoMediumText,
    required this.monoLargeText,
  });
  final Color? selectBackgroundColor;
  final Color? selectedTextColor;
  final Color? dropdownBackgroundColor;
  final Color? dropdownTextColor;
  final Color? headerDashboardActiveButton;
  final Color? headerTextColor;
  final Color? headerActiveTextColor;
  final Color? headerBackgroundColor;
  final Color? walletListBackgroundColor;
  final Color? walletActiveItemBorderColor;
  final Color? walletActiveItemBackgroundColor;
  final Color? walletItemBorderColor;
  final Color? inputIconColor;
  final Color? txBorderColor;
  final Color? txValuePositiveColor;
  final Color? txValueNegativeColor;
  final Color? stepBarActiveColor;
  final Color? stepBarColor;
  final Color? dialogBackground;
  final TextStyle? monoSmallText;
  final TextStyle? monoRegularText;
  final TextStyle? monoMediumText;
  final TextStyle? monoLargeText;
  @override
  ExtendedTheme copyWith({
    Color? selectBackgroundColor,
    Color? selectedTextColor,
    Color? dropdownBackgroundColor,
    Color? dropdownTextColor,
    Color? headerDashboardActiveButton,
    Color? walletListBackgroundColor,
    Color? walletActiveItemBorderColor,
    Color? walletItemBorderColor,
    Color? inputIconColor,
    Color? walletActiveItemBackgroundColor,
    Color? txBorderColor,
    Color? txValuePositiveColor,
    Color? txValueNegativeColor,
    Color? stepBarActiveColor,
    Color? stepBarColor,
    Color? dialogBackground,
    TextStyle? monoSmallText,
    TextStyle? monoRegularText,
    TextStyle? monoMediumText,
    TextStyle? monoLargeText,
  }) {
    return ExtendedTheme(
      selectBackgroundColor:
          selectBackgroundColor ?? this.selectBackgroundColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      dropdownBackgroundColor:
          dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
      headerDashboardActiveButton:
          headerDashboardActiveButton ?? this.headerDashboardActiveButton,
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
      txBorderColor: txBorderColor ?? this.txBorderColor,
      txValueNegativeColor: txValueNegativeColor ?? this.txValueNegativeColor,
      txValuePositiveColor: txValuePositiveColor ?? this.txValuePositiveColor,
      stepBarActiveColor: stepBarActiveColor ?? this.stepBarActiveColor,
      stepBarColor: stepBarColor ?? this.stepBarColor,
      dialogBackground: dialogBackground ?? this.dialogBackground,
      monoSmallText: monoSmallText ?? this.monoSmallText,
      monoRegularText: monoRegularText ?? this.monoRegularText,
      monoMediumText: monoMediumText ?? this.monoMediumText,
      monoLargeText: monoLargeText ?? this.monoLargeText,
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
      headerDashboardActiveButton: Color.lerp(
          headerDashboardActiveButton, other.headerDashboardActiveButton, t),
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
      txBorderColor: Color.lerp(txBorderColor, other.txBorderColor, t),
      txValueNegativeColor:
          Color.lerp(txValueNegativeColor, other.txValueNegativeColor, t),
      txValuePositiveColor:
          Color.lerp(txValuePositiveColor, other.txValuePositiveColor, t),
      stepBarActiveColor:
          Color.lerp(stepBarActiveColor, other.stepBarActiveColor, t),
      stepBarColor: Color.lerp(stepBarColor, other.stepBarColor, t),
      dialogBackground: Color.lerp(dialogBackground, other.dialogBackground, t),
      monoSmallText: TextStyle.lerp(monoSmallText, other.monoSmallText, t),
      monoRegularText:
          TextStyle.lerp(monoRegularText, other.monoRegularText, t),
      monoMediumText: TextStyle.lerp(monoMediumText, other.monoMediumText, t),
      monoLargeText: TextStyle.lerp(monoLargeText, other.monoLargeText, t),
    );
  }

  // the light theme
  static const light = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.darkBlue2,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.white,
    dropdownTextColor: WitnetPallet.darkGrey,
    headerDashboardActiveButton: WitnetPallet.white,
    headerActiveTextColor: WitnetPallet.witnetGreen2,
    headerTextColor: WitnetPallet.witnetGreen1,
    headerBackgroundColor: WitnetPallet.darkBlue2,
    walletListBackgroundColor: WitnetPallet.darkBlue2,
    walletActiveItemBackgroundColor: WitnetPallet.opacityWitnetGreen2,
    walletActiveItemBorderColor: WitnetPallet.witnetGreen3,
    walletItemBorderColor: WitnetPallet.lightGrey,
    inputIconColor: WitnetPallet.lightGrey,
    txBorderColor: WitnetPallet.lightGrey,
    txValueNegativeColor: WitnetPallet.darkRed,
    txValuePositiveColor: WitnetPallet.darkGreen,
    stepBarActiveColor: WitnetPallet.witnetGreen1,
    stepBarColor: WitnetPallet.darkGrey,
    dialogBackground: WitnetPallet.white,
    monoSmallText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.darkGrey,
        fontSize: 14),
    monoRegularText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.darkGrey,
        fontSize: 16),
    monoMediumText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.darkGrey,
        fontSize: 16),
    monoLargeText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.darkGrey,
        fontSize: 18),
  );
  // the dark theme
  static const dark = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.opacityWitnetGreen,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.opacityWitnetGreen,
    dropdownTextColor: WitnetPallet.white,
    headerDashboardActiveButton: WitnetPallet.opacityWhite2,
    headerActiveTextColor: WitnetPallet.white,
    headerTextColor: WitnetPallet.white,
    headerBackgroundColor: WitnetPallet.opacityWitnetGreen,
    walletListBackgroundColor: Color.fromRGBO(14, 41, 53, 1),
    walletActiveItemBackgroundColor: WitnetPallet.opacityWitnetGreen3,
    walletActiveItemBorderColor: WitnetPallet.witnetGreen2,
    walletItemBorderColor: WitnetPallet.opacityWhite2,
    inputIconColor: WitnetPallet.opacityWhite2,
    txBorderColor: WitnetPallet.opacityWhite2,
    txValueNegativeColor: WitnetPallet.brightRed,
    txValuePositiveColor: WitnetPallet.brightGreen,
    stepBarActiveColor: WitnetPallet.witnetGreen1,
    stepBarColor: WitnetPallet.opacityWhite,
    dialogBackground: WitnetPallet.opacityWitnetGreen,
    monoSmallText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.white,
        fontSize: 14),
    monoRegularText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.opacityWhite,
        fontSize: 16),
    monoMediumText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.white,
        fontSize: 16),
    monoLargeText: TextStyle(
        fontFamily: 'RobotoMono',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.white,
        fontSize: 18),
  );
}
