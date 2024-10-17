import 'package:flutter/material.dart';

class LabeledFormEntry extends StatelessWidget {
  LabeledFormEntry({
    Key? key,
    required this.label,
    required this.formEntry,
  });
  final String label;
  final Widget formEntry;
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            this.label,
            style: theme.textTheme.labelLarge,
          ),
          SizedBox(height: 8),
          this.formEntry,
        ]);
  }
}
