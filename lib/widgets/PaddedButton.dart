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
    return Padding(
      padding: padding,
      child: isPrimary ? primaryButton : secondaryButton,
    );
  }
}
