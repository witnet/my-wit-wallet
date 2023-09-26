import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

typedef void BoolCallback(bool value);

class CustomSwitch extends StatelessWidget {
  final bool checked;
  final String primaryLabel;
  final String? secondaryLabel;
  final BoolCallback onChanged;
  final FocusNode focusNode;
  final bool isFocused;

  const CustomSwitch(
      {required this.checked,
      required this.primaryLabel,
      required this.secondaryLabel,
      required this.onChanged,
      required this.isFocused,
      required this.focusNode});

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            primaryLabel,
            style: theme.textTheme.bodyLarge,
          )),
      Container(
          color: isFocused ? extendedTheme.focusBg : null,
          child: Switch(
            focusNode: focusNode,
            // This bool value toggles the switch.
            value: this.checked,
            onChanged: onChanged,
          )),
    ]);
  }
}
