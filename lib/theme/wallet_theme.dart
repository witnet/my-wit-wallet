import 'package:flutter/material.dart';

import 'dark_theme.dart' show darkTheme;
import 'light_theme.dart' show lightTheme;

enum WalletTheme {
  Light,
  Dark,

}

final walletThemeData = {
  WalletTheme.Light: lightTheme,
  WalletTheme.Dark: darkTheme,
};

Widget witnetLogo(ThemeData theme){
  return  (theme.brightness == Brightness.light)
      ? Image(image:AssetImage('assets/img/witnet_logo.png'))
      : Image(image:AssetImage('assets/img/witnet_logo_light.png'));
}
class WalletButtonTheme {
  const WalletButtonTheme({
    required this.backgroundColor,
    required this.highlightColor,
    required this.splashColor,
    required this.elevation,
    required this.highlightElevation,
    required this.shape,
  });
  final Color backgroundColor;
  final Color highlightColor;
  final Color splashColor;
  final double elevation;
  final double highlightElevation;
  final ShapeBorder shape;
}




