import 'package:flutter/material.dart';

class SuffixIcon extends StatelessWidget {
  SuffixIcon(
      {required this.onPressed,
      required this.icon,
      this.color,
      this.iconSize,
      required this.isFocus,
      required this.focusNode});

  final VoidCallback onPressed;
  final IconData icon;
  final bool isFocus;
  final double? iconSize;
  final Color? color;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusNode: focusNode,
        splashColor: Colors.transparent,
        icon: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
        onPressed: onPressed,
        color: isFocus
            ? theme.textSelectionTheme.cursorColor
            : theme.textTheme.bodyMedium!.color);
  }
}
