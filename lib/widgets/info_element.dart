import 'package:flutter/material.dart';

class InfoElement extends StatelessWidget {
  final String label;
  final String text;
  final Color? color;

  const InfoElement({
    required this.label,
    required this.text,
    this.color,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: theme.textTheme.headline3,
      ),
      SizedBox(height: 8),
      Text(text,
          style: (color != null
              ? theme.textTheme.bodyText1?.copyWith(color: color)
              : theme.textTheme.bodyText1)),
    ]);
  }
}
