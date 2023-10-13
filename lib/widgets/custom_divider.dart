import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider();

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Divider(
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: theme.dividerColor,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
