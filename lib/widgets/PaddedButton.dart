import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

const defaultIcon = Icon(null);

enum ButtonType {
  primary,
  secondary,
  text,
  horizontalIcon,
  verticalIcon,
  iconButton,
  stepbar,
  boxButton
}

Widget buildCircularProgress(context, theme) {
  return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: theme.textTheme.labelMedium?.color,
        strokeWidth: 2,
        value: null,
        semanticsLabel: 'Circular progress indicator',
      ));
}

class PaddedButton extends StatelessWidget {
  PaddedButton(
      {required this.padding,
      required this.text,
      required this.onPressed,
      this.color,
      this.fontSize = 16,
      this.isLoading = false,
      this.icon = defaultIcon,
      this.enabled = true,
      required this.type,
      this.label,
      this.container,
      this.iconSize = 16,
      this.darkBackground = false,
      this.autofocus});

  final EdgeInsets padding;
  final String text;
  final bool isLoading;
  final bool enabled;
  final Color? color;
  final ButtonType type;
  final Widget icon;
  final VoidCallback onPressed;
  final String? label;
  final Widget? container;
  final bool? autofocus;
  final double iconSize;
  final bool darkBackground;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == ButtonType.primary;
    final isText = type == ButtonType.text;
    final hasHorizontalIcon = type == ButtonType.horizontalIcon;
    final hasVerticalIcon = type == ButtonType.verticalIcon;
    final isIconButton = type == ButtonType.iconButton;
    final isStepBarButton = type == ButtonType.stepbar;
    final isBoxButton = type == ButtonType.boxButton;
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    Widget primaryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: isLoading ? buildCircularProgress(context, theme) : Text(text),
      onPressed: enabled ? onPressed : null,
    );

    Widget secondaryButton = OutlinedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: isLoading ? buildCircularProgress(context, theme) : Text(text),
      onPressed: onPressed,
    );

    Widget textButtonHorizontalIcon = TextButton(
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                  fontFamily: 'Almarai', fontSize: 14, color: color ?? null),
            ),
            Padding(padding: EdgeInsets.only(left: 8)),
            icon,
          ]),
      onPressed: onPressed,
    );

    Widget textButtonVerticalIcon = TextButton(
      style: color != null
          ? theme.textButtonTheme.style?.copyWith(
              foregroundColor: MaterialStateProperty.all(color),
              overlayColor:
                  MaterialStateProperty.all(WitnetPallet.transparentWhite))
          : theme.textButtonTheme.style,
      child: Column(children: [
        SizedBox(height: 8),
        icon,
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(fontFamily: 'Almarai', fontSize: 14),
        ),
        SizedBox(height: 8),
      ]),
      onPressed: onPressed,
    );

    Widget iconButton = SizedBox(
        height: iconSize + 20,
        width: iconSize + 20,
        child: TextButton(
          style: color != null
              ? theme.textButtonTheme.style?.copyWith(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  fixedSize: MaterialStateProperty.all(Size.zero),
                  foregroundColor: MaterialStateProperty.all(color),
                  overlayColor:
                      MaterialStateProperty.all(WitnetPallet.transparentWhite))
              : theme.textButtonTheme.style,
          child: Semantics(excludeSemantics: true, label: label, child: icon),
          onPressed: onPressed,
        ));

    Widget textButton = TextButton(
      style: color != null
          ? theme.textButtonTheme.style?.copyWith(
              foregroundColor: MaterialStateProperty.all(color),
              overlayColor:
                  MaterialStateProperty.all(WitnetPallet.transparentGrey))
          : theme.textButtonTheme.style,
      child: Text(
        text,
        style: color != null
            ? theme.textTheme.labelMedium
                ?.copyWith(color: color, fontSize: fontSize)
            : theme.textTheme.labelMedium,
      ),
      onPressed: onPressed,
    );

    Widget stepBarButton = TextButton(
      style: theme.textButtonTheme.style!.copyWith(
          overlayColor: MaterialStateProperty.all(extendedTheme.focusBg)),
      child: Text(
        text,
        style: color != null
            ? TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)
            : theme.textTheme.labelMedium,
      ),
      onPressed: onPressed,
    );

    Widget containerButton = TextButton(
      autofocus: autofocus ?? false,
      style: theme.textButtonTheme.style?.copyWith(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: MaterialStateProperty.all(darkBackground
              ? extendedTheme.darkBgFocusColor
              : extendedTheme.focusBg)),
      child: Semantics(
          label: label,
          excludeSemantics: true,
          child: container ?? Container()),
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
      } else if (isIconButton) {
        return iconButton;
      } else if (isStepBarButton) {
        return stepBarButton;
      } else if (isBoxButton) {
        return containerButton;
      } else {
        return secondaryButton;
      }
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: padding,
      child: _getButtonByType(),
    );
  }
}
