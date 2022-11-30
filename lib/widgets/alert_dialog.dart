import 'package:flutter/material.dart';

buildAlertDialog({
  required BuildContext context,
  required List<Widget> actions,
  required IconData icon,
  required String title,
  required String content,
}) {
  final theme = Theme.of(context);
  return Future.delayed(
      Duration.zero,
      () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                title,
                style: theme.textTheme.headline2,
              ),
              backgroundColor: theme.backgroundColor,
              icon: Icon(icon, size: 24),
              content: Text(content, style: theme.textTheme.bodyText1),
              actions: actions,
            ),
          ));
}
