import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';

buildAlertDialog({
  required BuildContext context,
  required List<Widget> actions,
  IconData? icon,
  Color? color,
  required String title,
  required Widget content,
  bool closable = true,
}) {
  final theme = Theme.of(context);
  return Future.delayed(
      Duration.zero,
      () => showDialog<String>(
            context: context,
            barrierDismissible: closable,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                textAlign: TextAlign.center,
                title,
                style: theme.textTheme.displayMedium,
              ),
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24))),
              icon: icon != null
                  ? Icon(icon,
                      size: 24, color: color ?? WitnetPallet.brightCyan)
                  : null,
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, top: 0),
              content: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300), child: content),
              actions: actions,
            ),
          ));
}
