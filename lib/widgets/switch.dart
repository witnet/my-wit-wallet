import 'package:flutter/material.dart';

typedef void BoolCallback(bool value);

class CustomSwitch extends StatelessWidget {
  final bool checked;
  final String primaryLabel;
  final String secondaryLabel;
  final BoolCallback onChanged;

  const CustomSwitch({
    required this.checked,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onChanged,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(
        secondaryLabel,
        style: theme.textTheme.bodyText1,
      ),
      Switch(
        // This bool value toggles the switch.
        value: this.checked,
        onChanged: (bool value) {
          onChanged(value);
        },
      ),
      Text(
        primaryLabel,
        style: theme.textTheme.bodyText1,
      ),
    ]);
  }
}
