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
                title,
                style: theme.textTheme.displayMedium,
              ),
              backgroundColor: theme.colorScheme.background,
              surfaceTintColor: theme.colorScheme.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              icon: icon != null
                  ? Icon(icon,
                      size: 24, color: color ?? WitnetPallet.witnetGreen1)
                  : null,
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, top: 0),
              content: content,
              actions: actions,
            ),
          ));
}
