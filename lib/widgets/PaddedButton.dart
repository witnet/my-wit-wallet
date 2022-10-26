import 'package:flutter/material.dart';

class PaddedButton extends StatelessWidget {
  PaddedButton({
    required this.padding,
    required this.text,
    required this.onPressed,
    this.enabled: true,
    required this.type,
  });

  final EdgeInsets padding;
  final String text;
  final bool enabled;
  final String type;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == 'primary';
    final isText = type == 'text';

    Widget primaryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: Text(text),
      onPressed: enabled ? onPressed : null,
    );

    Widget secondaryButton = OutlinedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: Text(text),
      onPressed: onPressed,
    );

    Widget textButton = TextButton(
      child: Text(text),
      onPressed: onPressed,
    );

    Widget _getButtonByType() {
      if (isPrimary) {
        return primaryButton;
      } else if (isText) {
        return textButton;
      } else {
        return secondaryButton;
      }
    }

    return Padding(
      padding: padding,
      child: _getButtonByType(),
    );
  }
}
