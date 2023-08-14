import 'package:flutter/material.dart';

buildAlertDialog({
  required BuildContext context,
  required List<Widget> actions,
  IconData? icon,
  Color? color,
  required String title,
  required Widget content,
}) {
  final theme = Theme.of(context);
  return Future.delayed(
      Duration.zero,
      () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                title,
                style: theme.textTheme.displayMedium,
              ),
              backgroundColor: theme.colorScheme.background,
              icon: Icon(icon, size: 24, color: color ?? null),
              content: content,
              actions: actions,
            ),
          ));
}
