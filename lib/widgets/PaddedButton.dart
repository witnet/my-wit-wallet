import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

const defaultIcon = Icon(null);

enum ButtonType {
  primary,
  secondary,
  text,
  small,
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
      this.attachedIcon = false,
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
  final bool attachedIcon;
  final Widget? container;
  final bool? autofocus;
  final double iconSize;
  final bool darkBackground;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    Color overlayColor() {
      if (!enabled) {
        return theme.colorScheme.background.withOpacity(0);
      }
      if (darkBackground) {
        return extendedTheme.darkBgFocusColor!;
      } else {
        return extendedTheme.focusBg!;
      }
    }

    Widget child = attachedIcon
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                Text(text),
                Padding(padding: EdgeInsets.only(left: 8)),
                icon,
              ])
        : Text(text);

    Widget primaryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: isLoading ? buildCircularProgress(context, theme) : child,
      onPressed: enabled ? onPressed : null,
    );

    Widget secondaryButton = OutlinedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: isLoading ? buildCircularProgress(context, theme) : Text(text),
      onPressed: onPressed,
    );

    Widget smallButton = OutlinedButton(
      style: ElevatedButton.styleFrom(padding: EdgeInsets.all(8)),
      child: isLoading
          ? buildCircularProgress(context, theme)
          : Text(
              text,
              style: TextStyle(fontSize: 10),
            ),
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
        height: iconSize + 22,
        width: iconSize + 22,
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
      style: theme.textButtonTheme.style!
          .copyWith(overlayColor: MaterialStateProperty.all(overlayColor())),
      child: Text(
        text,
        style: color != null
            ? TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)
            : theme.textTheme.labelMedium,
      ),
      onPressed: !enabled ? null : onPressed,
    );

    Widget containerButton = TextButton(
      autofocus: autofocus ?? false,
      style: theme.textButtonTheme.style?.copyWith(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: MaterialStateProperty.all(overlayColor())),
      child: Semantics(
          label: label,
          excludeSemantics: true,
          child: container ?? Container()),
      onPressed: !enabled ? null : onPressed,
    );

    Widget _getButtonByType() {
      switch (type) {
        case ButtonType.primary:
          return primaryButton;
        case ButtonType.secondary:
          return secondaryButton;
        case ButtonType.text:
          return textButton;
        case ButtonType.small:
          return smallButton;
        case ButtonType.iconButton:
          return iconButton;
        case ButtonType.horizontalIcon:
          return textButtonHorizontalIcon;
        case ButtonType.verticalIcon:
          return textButtonVerticalIcon;
        case ButtonType.boxButton:
          return containerButton;
        case ButtonType.stepbar:
          return stepBarButton;
      }
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: padding,
      child: _getButtonByType(),
    );
  }
}
