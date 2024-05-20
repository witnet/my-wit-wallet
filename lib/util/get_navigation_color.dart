import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/current_route.dart';

Color? getNavigationColor(
    {required BuildContext context, required dynamic route}) {
  final theme = Theme.of(context);
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return currentRoute(context) == route
      ? extendedTheme.bottomDashboardActiveButton
      : extendedTheme.inputIconColor;
}
