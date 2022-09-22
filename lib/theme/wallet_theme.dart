import 'package:flutter/material.dart';
import 'extended_theme.dart';
import 'dark_theme.dart' show darkTheme;
import 'light_theme.dart' show lightTheme;

enum WalletTheme {
  Light,
  Dark,
}

final walletThemeData = {
  WalletTheme.Light: lightTheme
      .copyWith(extensions: <ThemeExtension<dynamic>>[ExtendedTheme.light]),
  WalletTheme.Dark: darkTheme
      .copyWith(extensions: <ThemeExtension<dynamic>>[ExtendedTheme.dark]),
};

Widget witnetLogo(ThemeData theme) {
  return (theme.brightness == Brightness.light)
      ? Image(image: AssetImage('assets/img/witnet_logo.png'))
      : Image(image: AssetImage('assets/img/witnet_logo_light.png'));
}
