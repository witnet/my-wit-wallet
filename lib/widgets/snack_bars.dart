import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

SnackBar buildCopiedSnackbar(ThemeData theme, String text) {
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return SnackBar(
    width: 150,
    clipBehavior: Clip.none,
    content: Text(text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium!
            .copyWith(color: extendedTheme.copiedSnackbarText)),
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    backgroundColor: extendedTheme.copiedSnackbarBg,
    elevation: 0,
  );
}

SnackBar buildExplorerConnectionSnackbar(
    ThemeData theme, String text, Color? color,
    [Function? action]) {
  return SnackBar(
    clipBehavior: Clip.none,
    action: action != null
        ? SnackBarAction(
            label: 'Dismiss',
            onPressed: () => action(),
            textColor: Colors.white,
          )
        : null,
    content: Text(text,
        textAlign: TextAlign.left,
        style: theme.textTheme.bodyMedium!.copyWith(color: Colors.white)),
    duration: Duration(hours: 1),
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    elevation: 0,
  );
}
