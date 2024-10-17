import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

typedef void BoolCallback(bool? value);

class LabeledCheckbox extends StatelessWidget {
  final bool checked;
  final String label;
  final BoolCallback onChanged;
  final bool isFocus;
  final FocusNode focusNode;

  const LabeledCheckbox({
    required this.checked,
    required this.label,
    required this.isFocus,
    required this.focusNode,
    required this.onChanged,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Container(
        color: isFocus ? extendedTheme.focusBg : null,
        child: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(left: 0, top: 8, bottom: 8),
                child: Checkbox(
                  focusNode: focusNode,
                  value: checked,
                  onChanged: (value) {
                    onChanged(value);
                  },
                )),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  final bool valueToSend = !checked;
                  onChanged(valueToSend);
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  child: Text(
                    label,
                    style: checked
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyMedium?.color),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
