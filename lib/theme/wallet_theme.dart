import 'package:flutter/material.dart';
import 'extended_theme.dart';
import 'dark_theme.dart' show darkTheme;
import 'light_theme.dart' show lightTheme;

enum WalletTheme {
  Light,
  Dark,
}

Map<WalletTheme, ThemeData> walletThemeData = {
  WalletTheme.Light: lightTheme
      .copyWith(extensions: <ThemeExtension<dynamic>>[ExtendedTheme.light]),
  WalletTheme.Dark: darkTheme
      .copyWith(extensions: <ThemeExtension<dynamic>>[ExtendedTheme.dark]),
};

Widget witnetLogo(ThemeData theme) {
  return (theme.primaryColor == lightTheme.primaryColor)
      ? Image.asset(
          'assets/img/witnet_light_logo.png',
          width: 800,
          height: 139.68,
          fit: BoxFit.fitWidth,
        )
      : Image.asset(
          'assets/img/witnet_dark_logo.png',
          width: 800,
          height: 139.68,
          fit: BoxFit.fitWidth,
        );
}

Widget witnetEyeIcon(ThemeData theme, {height = 100}) {
  return (theme.primaryColor == lightTheme.primaryColor)
      ? Image.asset(
          'assets/img/witnet_light_icon.png',
          width: 100,
          height: height,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        )
      : Image.asset(
          'assets/img/witnet_dark_icon.png',
          width: 100,
          height: height,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        );
}

Widget smallWitnetEyeIcon(ThemeData theme) {
  return (theme.primaryColor == lightTheme.primaryColor)
      ? Image.asset(
          'assets/img/witnet_light_icon.png',
          height: 50,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        )
      : Image.asset(
          'assets/img/witnet_dark_icon.png',
          height: 50,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        );
}
