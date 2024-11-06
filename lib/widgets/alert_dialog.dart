import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

buildAlertDialog({
  required BuildContext context,
  required List<Widget> actions,
  IconData? icon,
  Widget? image,
  Color? color,
  required String title,
  required Widget content,
  bool closable = true,
}) {
  final theme = Theme.of(context);
  final extendedTheme = theme.extension<ExtendedTheme>()!;

  Widget? getIcon() {
    if (icon != null)
      return Align(
          alignment: Alignment.centerLeft,
          child: Icon(icon, size: 24, color: color ?? WitnetPallet.brightCyan));
    else
      return null;
  }

  return Future.delayed(
      Duration.zero,
      () => showDialog<String>(
            context: context,
            barrierDismissible: closable,
            builder: (BuildContext context) => AlertDialog(
              title: null,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(extendedTheme.borderRadius!)),
              icon: getIcon(),
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, top: 0),
              content: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (image != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: image,
                          ),
                        SizedBox(height: 8),
                        Text(title,
                            style: theme.textTheme.titleLarge,
                            textAlign: TextAlign.left),
                        SizedBox(height: 8),
                        content
                      ])),
              actions: actions,
            ),
          ));
}
