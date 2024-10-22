import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'colors.dart';

@immutable
class ExtendedTheme extends ThemeExtension<ExtendedTheme> {
  const ExtendedTheme(
      {required this.monoBoldText,
      required this.monoLargeText,
      required this.selectBackgroundColor,
      required this.selectedTextColor,
      required this.dropdownBackgroundColor,
      required this.dropdownTextColor,
      required this.navigationActiveButton,
      required this.headerBackgroundColor,
      required this.headerTextColor,
      required this.headerActiveTextColor,
      required this.panelBgColor,
      required this.walletListBackgroundColor,
      required this.walletActiveItemBackgroundColor,
      required this.walletActiveItemBorderColor,
      required this.walletItemBorderColor,
      required this.inputIconColor,
      required this.txBorderColor,
      required this.txValuePositiveColor,
      required this.txValueNegativeColor,
      required this.stepBarActiveColor,
      required this.stepBarActionableColor,
      required this.stepBarColor,
      required this.switchActiveBg,
      required this.switchActiveFg,
      required this.switchInactiveBg,
      required this.switchInactiveFg,
      required this.switchBorderColor,
      required this.dialogBackground,
      required this.copiedSnackbarBg,
      required this.copiedSnackbarText,
      required this.monoRegularText,
      required this.spinnerColor,
      required this.errorColor,
      required this.activeClickableBoxBgColor,
      required this.activeClickableBoxBorderColor,
      required this.inactiveClickableBoxBgColor,
      required this.inactiveClickableBoxBorderColor,
      required this.numberPaginatiorSelectedBg,
      required this.numberPaginatiorUnselectedFg,
      required this.darkBgFocusColor,
      required this.focusBg,
      required this.hdWalletTypeBgColor,
      required this.singleWalletBgColor,
      required this.warningColor,
      required this.backgroundBox,
      required this.regularPanelText,
      required this.mediumPanelText,
      required this.navigationColor,
      required this.navigationPointerActiveButton,
      required this.monoSmallText,
      required this.monoMediumText,
      required this.borderRadius});
  final Color? selectBackgroundColor;
  final Color? selectedTextColor;
  final Color? dropdownBackgroundColor;
  final Color? dropdownTextColor;
  final Color? navigationActiveButton;
  final Color? headerTextColor;
  final Color? headerActiveTextColor;
  final Color? headerBackgroundColor;
  final Color? panelBgColor;
  final Color? walletListBackgroundColor;
  final Color? walletActiveItemBorderColor;
  final Color? walletActiveItemBackgroundColor;
  final Color? walletItemBorderColor;
  final Color? inputIconColor;
  final Color? txBorderColor;
  final Color? txValuePositiveColor;
  final Color? txValueNegativeColor;
  final Color? stepBarActiveColor;
  final Color? stepBarActionableColor;
  final Color? stepBarColor;
  final Color? switchActiveBg;
  final Color? switchActiveFg;
  final Color? switchInactiveBg;
  final Color? switchInactiveFg;
  final Color? switchBorderColor;
  final Color? dialogBackground;
  final Color? copiedSnackbarBg;
  final Color? copiedSnackbarText;
  final TextStyle? monoSmallText;
  final TextStyle? monoRegularText;
  final TextStyle? monoMediumText;
  final TextStyle? monoBoldText;
  final TextStyle? monoLargeText;
  final Color? spinnerColor;
  final Color? errorColor;
  final Color? activeClickableBoxBgColor;
  final Color? activeClickableBoxBorderColor;
  final Color? inactiveClickableBoxBgColor;
  final Color? inactiveClickableBoxBorderColor;
  final Color? numberPaginatiorSelectedBg;
  final Color? numberPaginatiorUnselectedFg;
  final Color? darkBgFocusColor;
  final Color? focusBg;
  final Color? hdWalletTypeBgColor;
  final Color? singleWalletBgColor;
  final Color? warningColor;
  final Color? backgroundBox;
  final Color? navigationColor;
  final Color? navigationPointerActiveButton;
  final TextStyle? regularPanelText;
  final TextStyle? mediumPanelText;
  final Radius? borderRadius;
  @override
  ExtendedTheme copyWith(
      {Color? selectBackgroundColor,
      Color? selectedTextColor,
      Color? dropdownBackgroundColor,
      Color? dropdownTextColor,
      Color? navigationActiveButton,
      Color? panelBgColor,
      Color? walletListBackgroundColor,
      Color? walletActiveItemBorderColor,
      Color? walletItemBorderColor,
      Color? inputIconColor,
      Color? walletActiveItemBackgroundColor,
      Color? txBorderColor,
      Color? txValuePositiveColor,
      Color? txValueNegativeColor,
      Color? stepBarActiveColor,
      Color? stepBarActionableColor,
      Color? stepBarColor,
      Color? switchActiveBg,
      Color? switchActiveFg,
      Color? switchInactiveBg,
      Color? switchInactiveFg,
      Color? switchBorderColor,
      Color? dialogBackground,
      Color? copiedSnackbarBg,
      Color? copiedSnackbarText,
      TextStyle? monoSmallText,
      TextStyle? monoRegularText,
      TextStyle? monoMediumText,
      TextStyle? monoLargeText,
      Color? spinnerColor,
      Color? errorColor,
      Color? activeClickableBoxBgColor,
      Color? activeClickableBoxBorderColor,
      Color? inactiveClickableBoxBgColor,
      Color? inactiveClickableBoxBorderColo,
      Color? numberPaginatiorSelectedBg,
      Color? numberPaginatiorUnselectedFg,
      Color? darkBgFocusColor,
      Color? focusBg,
      Color? hdWalletTypeBgColor,
      Color? singleWalletBgColor,
      Color? warningColor,
      Color? backgroundBox,
      TextStyle? regularPanelText,
      TextStyle? mediumPanelText,
      Color? navigationColor,
      Color? navigationPointerActiveButton,
      Radius? borderRadius,
      r}) {
    return ExtendedTheme(
        selectBackgroundColor:
            selectBackgroundColor ?? this.selectBackgroundColor,
        selectedTextColor: selectedTextColor ?? this.selectedTextColor,
        dropdownBackgroundColor:
            dropdownBackgroundColor ?? this.dropdownBackgroundColor,
        dropdownTextColor: dropdownTextColor ?? this.dropdownTextColor,
        navigationActiveButton:
            navigationActiveButton ?? this.navigationActiveButton,
        navigationPointerActiveButton:
            navigationPointerActiveButton ?? this.navigationPointerActiveButton,
        headerBackgroundColor:
            headerBackgroundColor ?? this.headerBackgroundColor,
        headerTextColor: headerTextColor ?? this.headerTextColor,
        headerActiveTextColor:
            headerActiveTextColor ?? this.headerActiveTextColor,
        panelBgColor: panelBgColor ?? this.panelBgColor,
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
        stepBarActionableColor:
            stepBarActionableColor ?? this.stepBarActionableColor,
        stepBarColor: stepBarColor ?? this.stepBarColor,
        switchActiveBg: switchActiveBg ?? this.switchActiveBg,
        switchActiveFg: switchActiveFg ?? this.switchActiveFg,
        switchInactiveBg: switchInactiveBg ?? this.switchInactiveBg,
        switchInactiveFg: switchInactiveFg ?? this.switchInactiveFg,
        switchBorderColor: switchBorderColor ?? this.switchBorderColor,
        spinnerColor: spinnerColor ?? this.spinnerColor,
        errorColor: errorColor ?? this.errorColor,
        activeClickableBoxBgColor:
            activeClickableBoxBgColor ?? this.activeClickableBoxBgColor,
        activeClickableBoxBorderColor:
            activeClickableBoxBorderColor ?? this.activeClickableBoxBorderColor,
        inactiveClickableBoxBgColor:
            inactiveClickableBoxBgColor ?? this.inactiveClickableBoxBgColor,
        inactiveClickableBoxBorderColor: inactiveClickableBoxBorderColor ??
            this.inactiveClickableBoxBorderColor,
        dialogBackground: dialogBackground ?? this.dialogBackground,
        copiedSnackbarBg: copiedSnackbarBg ?? copiedSnackbarBg,
        copiedSnackbarText: copiedSnackbarText ?? copiedSnackbarText,
        monoRegularText: monoRegularText ?? this.monoRegularText,
        numberPaginatiorSelectedBg:
            numberPaginatiorSelectedBg ?? this.numberPaginatiorSelectedBg,
        numberPaginatiorUnselectedFg:
            numberPaginatiorUnselectedFg ?? this.numberPaginatiorUnselectedFg,
        darkBgFocusColor: darkBgFocusColor ?? this.darkBgFocusColor,
        focusBg: focusBg ?? this.focusBg,
        hdWalletTypeBgColor: hdWalletTypeBgColor ?? this.hdWalletTypeBgColor,
        singleWalletBgColor: singleWalletBgColor ?? this.singleWalletBgColor,
        warningColor: warningColor ?? this.warningColor,
        backgroundBox: backgroundBox ?? this.backgroundBox,
        regularPanelText: regularPanelText ?? this.regularPanelText,
        mediumPanelText: mediumPanelText ?? this.mediumPanelText,
        navigationColor: navigationColor ?? this.navigationColor,
        monoBoldText: monoBoldText ?? this.monoBoldText,
        monoLargeText: monoLargeText ?? this.monoLargeText,
        monoSmallText: monoSmallText ?? this.monoSmallText,
        monoMediumText: monoMediumText ?? this.monoMediumText,
        borderRadius: borderRadius ?? this.borderRadius);
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
      navigationActiveButton:
          Color.lerp(navigationActiveButton, other.navigationActiveButton, t),
      navigationPointerActiveButton: Color.lerp(navigationPointerActiveButton,
          other.navigationPointerActiveButton, t),
      headerBackgroundColor:
          Color.lerp(headerBackgroundColor, other.dropdownTextColor, t),
      headerTextColor: Color.lerp(headerTextColor, other.dropdownTextColor, t),
      headerActiveTextColor:
          Color.lerp(headerActiveTextColor, other.dropdownTextColor, t),
      panelBgColor: Color.lerp(panelBgColor, other.panelBgColor, t),
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
      stepBarActionableColor:
          Color.lerp(stepBarActiveColor, other.stepBarActionableColor, t),
      stepBarColor: Color.lerp(stepBarColor, other.stepBarColor, t),
      dialogBackground: Color.lerp(dialogBackground, other.dialogBackground, t),
      switchActiveBg: Color.lerp(switchActiveBg, other.switchActiveBg, t),
      switchActiveFg: Color.lerp(switchActiveFg, other.switchActiveFg, t),
      switchInactiveBg: Color.lerp(switchInactiveBg, other.switchInactiveBg, t),
      switchInactiveFg: Color.lerp(switchInactiveFg, other.switchInactiveFg, t),
      switchBorderColor:
          Color.lerp(switchBorderColor, other.switchBorderColor, t),
      spinnerColor: Color.lerp(spinnerColor, other.spinnerColor, t),
      errorColor: Color.lerp(errorColor, other.errorColor, t),
      activeClickableBoxBgColor: Color.lerp(
          activeClickableBoxBgColor, other.activeClickableBoxBgColor, t),
      activeClickableBoxBorderColor: Color.lerp(activeClickableBoxBorderColor,
          other.activeClickableBoxBorderColor, t),
      inactiveClickableBoxBgColor: Color.lerp(
          inactiveClickableBoxBgColor, other.inactiveClickableBoxBgColor, t),
      inactiveClickableBoxBorderColor: Color.lerp(
          inactiveClickableBoxBorderColor,
          other.inactiveClickableBoxBorderColor,
          t),
      numberPaginatiorSelectedBg: Color.lerp(
          numberPaginatiorSelectedBg, other.numberPaginatiorSelectedBg, t),
      numberPaginatiorUnselectedFg: Color.lerp(
          numberPaginatiorUnselectedFg, other.numberPaginatiorUnselectedFg, t),
      copiedSnackbarBg: Color.lerp(copiedSnackbarBg, other.copiedSnackbarBg, t),
      copiedSnackbarText:
          Color.lerp(copiedSnackbarText, other.copiedSnackbarText, t),
      monoRegularText:
          TextStyle.lerp(monoRegularText, other.monoRegularText, t),
      darkBgFocusColor: Color.lerp(darkBgFocusColor, other.darkBgFocusColor, t),
      focusBg: Color.lerp(focusBg, other.focusBg, t),
      hdWalletTypeBgColor:
          Color.lerp(hdWalletTypeBgColor, other.hdWalletTypeBgColor, t),
      singleWalletBgColor:
          Color.lerp(singleWalletBgColor, other.singleWalletBgColor, t),
      warningColor: Color.lerp(warningColor, other.warningColor, t),
      backgroundBox: Color.lerp(backgroundBox, other.backgroundBox, t),
      regularPanelText:
          TextStyle.lerp(regularPanelText, other.regularPanelText, t),
      mediumPanelText:
          TextStyle.lerp(mediumPanelText, other.mediumPanelText, t),
      navigationColor: Color.lerp(navigationColor, other.navigationColor, t),
      monoBoldText: TextStyle.lerp(monoBoldText, other.monoBoldText, t),
      monoLargeText: TextStyle.lerp(monoLargeText, other.monoLargeText, t),
      monoSmallText: TextStyle.lerp(monoSmallText, other.monoSmallText, t),
      monoMediumText: TextStyle.lerp(monoMediumText, other.monoMediumText, t),
      borderRadius: Radius.lerp(borderRadius, borderRadius, t),
    );
  }

  // the light theme
  static const light = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.black,
    selectedTextColor: WitnetPallet.white,
    dropdownBackgroundColor: WitnetPallet.white,
    dropdownTextColor: WitnetPallet.darkGrey,
    navigationActiveButton: WitnetPallet.lightGrey,
    navigationPointerActiveButton: WitnetPallet.black,
    headerActiveTextColor: WitnetPallet.black,
    headerTextColor: WitnetPallet.black,
    headerBackgroundColor: WitnetPallet.brightCyan,
    panelBgColor: WitnetPallet.lighterGrey,
    walletListBackgroundColor: WitnetPallet.transparentGrey2,
    walletActiveItemBackgroundColor: WitnetPallet.brightCyanOpacity3,
    walletActiveItemBorderColor: WitnetPallet.brightCyan,
    walletItemBorderColor: WitnetPallet.transparentGrey2,
    inputIconColor: WitnetPallet.lightGrey,
    navigationColor: WitnetPallet.black,
    txBorderColor: WitnetPallet.lightGrey,
    txValueNegativeColor: WitnetPallet.darkRed,
    txValuePositiveColor: WitnetPallet.darkGreen,
    stepBarActiveColor: WitnetPallet.black,
    stepBarActionableColor: WitnetPallet.mediumGrey,
    stepBarColor: WitnetPallet.lightGrey,
    switchActiveBg: WitnetPallet.black,
    switchActiveFg: WitnetPallet.white,
    switchInactiveBg: WitnetPallet.white,
    switchInactiveFg: WitnetPallet.darkGrey,
    switchBorderColor: WitnetPallet.black,
    spinnerColor: WitnetPallet.brightCyan,
    errorColor: WitnetPallet.darkRed,
    warningColor: WitnetPallet.darkOrange,
    activeClickableBoxBgColor: WitnetPallet.brightCyanOpacity3,
    activeClickableBoxBorderColor: WitnetPallet.brightCyan,
    inactiveClickableBoxBgColor: WitnetPallet.white,
    inactiveClickableBoxBorderColor: WitnetPallet.lightGrey,
    dialogBackground: WitnetPallet.white,
    numberPaginatiorSelectedBg: WitnetPallet.black,
    numberPaginatiorUnselectedFg: WitnetPallet.darkGrey,
    copiedSnackbarBg: Colors.black,
    copiedSnackbarText: WitnetPallet.white,
    darkBgFocusColor: Color.fromARGB(21, 65, 190, 165),
    focusBg: Color.fromARGB(7, 1, 1, 1),
    backgroundBox: Color.fromRGBO(114, 114, 114, 0.08),
    hdWalletTypeBgColor: WitnetPallet.mediumGrey,
    singleWalletBgColor: WitnetPallet.brown,
    monoSmallText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.darkGrey,
        fontSize: 14),
    monoRegularText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.darkGrey,
        fontSize: 16),
    monoMediumText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w500,
        color: WitnetPallet.darkGrey,
        fontSize: 16),
    monoLargeText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w500,
        color: WitnetPallet.darkGrey,
        fontSize: 18),
    monoBoldText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.darkGrey,
        fontSize: 16),
    regularPanelText: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.darkerGrey,
        fontSize: 16),
    mediumPanelText: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
        color: WitnetPallet.darkerGrey,
        fontSize: 16),
    borderRadius: Radius.circular(BORDER_RADIUS),
  );
  // the dark theme
  static const dark = ExtendedTheme(
    selectBackgroundColor: WitnetPallet.brightCyan,
    selectedTextColor: WitnetPallet.black,
    dropdownBackgroundColor: WitnetPallet.darkerGrey,
    dropdownTextColor: WitnetPallet.lighterGrey,
    navigationPointerActiveButton: WitnetPallet.lightGrey,
    navigationActiveButton: WitnetPallet.lightGrey,
    headerActiveTextColor: WitnetPallet.black,
    headerTextColor: WitnetPallet.black,
    headerBackgroundColor: WitnetPallet.brightCyan,
    panelBgColor: WitnetPallet.darkerGrey,
    walletListBackgroundColor: WitnetPallet.darkerGrey,
    walletActiveItemBackgroundColor: WitnetPallet.brightCyanOpacity3,
    walletActiveItemBorderColor: WitnetPallet.brightCyan,
    walletItemBorderColor: WitnetPallet.opacityWhite2,
    inputIconColor: WitnetPallet.white,
    txBorderColor: WitnetPallet.darkGrey2,
    txValueNegativeColor: WitnetPallet.brightRed,
    txValuePositiveColor: WitnetPallet.brightGreen,
    stepBarActiveColor: WitnetPallet.brightCyan,
    stepBarActionableColor: WitnetPallet.white,
    stepBarColor: WitnetPallet.opacityWhite,
    switchActiveBg: WitnetPallet.brightCyan,
    switchActiveFg: WitnetPallet.black,
    switchInactiveBg: WitnetPallet.black,
    switchInactiveFg: WitnetPallet.white,
    switchBorderColor: WitnetPallet.brightCyan,
    spinnerColor: WitnetPallet.brightCyan,
    errorColor: WitnetPallet.brightRed,
    warningColor: WitnetPallet.brightOrange,
    activeClickableBoxBgColor: WitnetPallet.brightCyanOpacity3,
    activeClickableBoxBorderColor: WitnetPallet.brightCyan,
    inactiveClickableBoxBgColor: WitnetPallet.black,
    inactiveClickableBoxBorderColor: WitnetPallet.opacityWhite2,
    dialogBackground: WitnetPallet.brightCyanOpacity1,
    numberPaginatiorSelectedBg: WitnetPallet.brightCyan,
    numberPaginatiorUnselectedFg: WitnetPallet.white,
    copiedSnackbarBg: WitnetPallet.white,
    copiedSnackbarText: WitnetPallet.black,
    darkBgFocusColor: Color.fromARGB(21, 65, 190, 165),
    focusBg: Color.fromARGB(14, 255, 255, 255),
    backgroundBox: Color.fromARGB(14, 255, 255, 255),
    hdWalletTypeBgColor: WitnetPallet.mediumGrey,
    singleWalletBgColor: WitnetPallet.brown,
    navigationColor: WitnetPallet.black,
    monoSmallText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.white,
        fontSize: 14),
    monoRegularText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.white,
        fontSize: 16),
    monoMediumText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.white,
        fontSize: 16),
    monoBoldText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.white,
        fontSize: 16),
    monoLargeText: TextStyle(
        fontFamily: 'NimbusMono',
        fontWeight: FontWeight.w500,
        color: WitnetPallet.white,
        fontSize: 18),
    regularPanelText: TextStyle(
        fontFamily: 'Almarai',
        fontWeight: FontWeight.w400,
        color: WitnetPallet.white,
        fontSize: 16),
    mediumPanelText: TextStyle(
        fontFamily: 'Almarai',
        fontWeight: FontWeight.w700,
        color: WitnetPallet.white,
        fontSize: 16),
    borderRadius: Radius.circular(BORDER_RADIUS),
  );
}
