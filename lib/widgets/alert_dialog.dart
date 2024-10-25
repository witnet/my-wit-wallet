import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

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
  final extendedTheme = theme.extension<ExtendedTheme>()!;
  return Future.delayed(
      Duration.zero,
      () => showDialog<String>(
            context: context,
            barrierDismissible: closable,
            builder: (BuildContext context) => AlertDialog(
              title: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null)
                      Icon(
                        icon,
                        size: 24,
                        color: color ?? WitnetPallet.brightCyan,
                      ),
                    const SizedBox(width: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
              ),
              actionsPadding: EdgeInsets.only(bottom: 16, right: 16, top: 0),
              content: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300), child: content),
              actions: actions,
            ),
          ));
}
