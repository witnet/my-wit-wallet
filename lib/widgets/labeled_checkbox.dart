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
        Checkbox(
          value: checked,
          onChanged: (value) {
            onChanged(value);
          },
        ),
        Padding(
            padding: EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () {
                final bool valueToSend = !checked;
                onChanged(valueToSend);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
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
