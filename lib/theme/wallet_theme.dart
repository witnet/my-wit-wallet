import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          height: height,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        )
      : Image.asset(
          'assets/img/witnet_dark_icon.png',
          height: height,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
        );
}

Widget svgThemeImage(ThemeData theme, {name, double height = 100}) {
  return (theme.primaryColor == lightTheme.primaryColor)
      ? SvgPicture.asset(
          'assets/svg/$name.svg',
          height: height,
          fit: BoxFit.fitWidth,
        )
      : SvgPicture.asset(
          'assets/svg/$name-dark.svg',
          height: height,
          fit: BoxFit.fitWidth,
        );
}
