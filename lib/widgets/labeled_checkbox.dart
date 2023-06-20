import 'package:flutter/material.dart';

typedef void BoolCallback(bool? value);

class LabeledCheckbox extends StatelessWidget {
  final bool checked;
  final String label;
  final BoolCallback onChanged;

  const LabeledCheckbox({
    required this.checked,
    required this.label,
    required this.onChanged,
  });

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 0, top: 8, bottom: 8),
            child: Checkbox(
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
                child: Text(label,
                    style: checked
                        ? theme.textTheme.labelMedium
                        : theme.textTheme.bodyLarge),
              ),
            ))
      ],
    );
  }
}
