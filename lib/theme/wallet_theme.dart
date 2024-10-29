import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_wit_wallet/constants.dart';
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

Widget svgImage({name, double? height, double? width}) {
  return SvgPicture.asset(
    'assets/svg/$name.svg',
    height: height,
    width: width,
    fit: BoxFit.fitWidth,
  );
}

Widget svgThemeImage(ThemeData theme, {name, double? height, double? width}) {
  Widget? lightIcon;
  Widget? darkIcon;
  if (CUSTOM_ICON_NAMES.contains(name)) {
    lightIcon = SvgPicture.asset(
      'assets/svg/$name.svg',
      height: height,
      width: width,
      fit: BoxFit.fitWidth,
    );
  }
  if (CUSTOM_ICON_NAMES.contains('$name-dark')) {
    darkIcon = SvgPicture.asset(
      'assets/svg/$name-dark.svg',
      height: height,
      width: width,
      fit: BoxFit.fitWidth,
    );
  }
  if (darkIcon != null && theme.primaryColor == darkTheme.primaryColor) {
    return darkIcon;
  } else if (lightIcon != null) {
    return lightIcon;
  } else {
    return Container();
  }
}
