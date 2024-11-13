import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

class TextBtn extends CustomButton {
  TextBtn({
    required super.text,
    required super.padding,
    required super.onPressed,
    super.color,
    this.fontSize = 16,
    this.boldText = false,
  });

  final double fontSize;
  final bool boldText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return super.buildWithPadding(
        child: TextButton(
      style: color != null
          ? theme.textButtonTheme.style?.copyWith(
              foregroundColor: WidgetStateProperty.all(color),
              overlayColor:
                  WidgetStateProperty.all(WitnetPallet.transparentGrey))
          : theme.textButtonTheme.style,
      child: Text(
        text,
        style: color != null
            ? theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontSize: fontSize,
                fontWeight: boldText ? FontWeight.bold : FontWeight.normal)
            : theme.textTheme.titleMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: boldText ? FontWeight.bold : FontWeight.normal),
      ),
      onPressed: onPressed,
    ));
  }
}
