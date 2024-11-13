import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

enum IconBtnType { horizontalText, verticalText, icon }

class IconBtn extends CustomButton {
  IconBtn({
    required super.text,
    required super.padding,
    required super.onPressed,
    required this.label,
    super.color,
    super.iconPosition,
    required super.icon,
    this.iconSize = 16,
    this.hoverPadding = 22,
    this.iconBtnType = IconBtnType.horizontalText,
    this.alignment = MainAxisAlignment.center,
  });

  final num hoverPadding;
  final String label;
  final double iconSize;
  final MainAxisAlignment alignment;
  final IconBtnType iconBtnType;

  Widget buildIconButton(ThemeData theme) {
    switch (this.iconBtnType) {
      case IconBtnType.verticalText:
        return TextButton(
          style: color != null
              ? theme.textButtonTheme.style?.copyWith(
                  foregroundColor: WidgetStateProperty.all(color),
                  overlayColor:
                      WidgetStateProperty.all(WitnetPallet.transparentWhite))
              : theme.textButtonTheme.style,
          child: Column(children: [
            SizedBox(height: 8),
            icon,
            SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.titleMedium!.copyWith(fontSize: 14),
            ),
            SizedBox(height: 8),
          ]),
          onPressed: onPressed,
        );
      case IconBtnType.horizontalText:
        return TextButton(
          child: Row(
              mainAxisAlignment: alignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                iconPosition == IconPosition.left ? icon : Container(),
                iconPosition == IconPosition.left
                    ? SizedBox(width: 8)
                    : Container(),
                Text(text, style: theme.textTheme.labelLarge),
                Padding(padding: EdgeInsets.only(left: 8)),
                iconPosition == IconPosition.right ? icon : Container(),
              ]),
          onPressed: onPressed,
        );
      case IconBtnType.icon:
        return SizedBox(
            height: iconSize + hoverPadding,
            width: iconSize + hoverPadding,
            child: TextButton(
              style: color != null
                  ? theme.textButtonTheme.style?.copyWith(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                      fixedSize: WidgetStateProperty.all(Size.zero),
                      foregroundColor: WidgetStateProperty.all(color),
                      overlayColor: WidgetStateProperty.all(
                          WitnetPallet.transparentWhite))
                  : theme.textButtonTheme.style,
              child:
                  Semantics(excludeSemantics: true, label: label, child: icon),
              onPressed: onPressed,
            ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return super.buildWithPadding(child: buildIconButton(theme));
  }
}
