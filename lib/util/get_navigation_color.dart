import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/current_route.dart';

Color? getNavigationColor(
    {required BuildContext context, required List<String> routesList}) {
  final theme = Theme.of(context);
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return routesList.contains(currentRoute(context))
      ? extendedTheme.navigationActiveButton
      : extendedTheme.inputIconColor;
}
