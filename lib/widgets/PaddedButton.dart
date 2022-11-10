import 'package:flutter/material.dart';

const defaultIcon = Icon(null);

class PaddedButton extends StatelessWidget {
  PaddedButton({
    required this.padding,
    required this.text,
    required this.onPressed,
    this.icon = defaultIcon,
    this.enabled: true,
    required this.type,
  });

  final EdgeInsets padding;
  final String text;
  final bool enabled;
  final String type;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == 'primary';
    final isText = type == 'text';
    final hasHorizontalIcon = type == 'horizontal-icon';
    final hasVerticalIcon = type == 'vertical-icon';

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

    Widget textButtonHorizontalIcon = TextButton(
      child: Row(children: [
        Text(text),
        Padding(padding: EdgeInsets.only(left: 8)),
        icon,
      ]),
      onPressed: onPressed,
    );

    Widget textButtonVerticalIcon = TextButton(
      child: Column(children: [
        icon,
        Text(text, style: TextStyle(fontSize: 12)),
      ]),
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
      } else if (hasVerticalIcon) {
        return textButtonVerticalIcon;
      } else if (hasHorizontalIcon) {
        return textButtonHorizontalIcon;
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
