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
  boxButton,
  sufix
}

enum IconPosition { left, right }

Widget buildCircularProgress(context, ThemeData theme) {
  return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        color: theme.colorScheme.surface,
        strokeWidth: 2,
        value: null,
        semanticsLabel: 'Circular progress indicator',
      ));
}

class BaseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class PrimaryButton extends BaseButton {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class PaddedButton extends StatelessWidget {
  PaddedButton(
      {required this.padding,
      required this.text,
      required this.onPressed,
      this.color,
      this.sizeCover = true,
      this.fontSize = 16,
      this.boldText = false,
      this.isLoading = false,
      this.icon = defaultIcon,
      this.enabled = true,
      required this.type,
      this.label,
      this.container,
      this.attachedIcon = false,
      this.iconSize = 16,
      this.darkBackground = false,
      this.alignment = MainAxisAlignment.center,
      this.iconPosition = IconPosition.right,
      this.autofocus});

  final EdgeInsets padding;
  final bool sizeCover;
  final String text;
  final bool isLoading;
  final bool enabled;
  final Color? color;
  final ButtonType type;
  final Widget icon;
  final bool boldText;
  final VoidCallback onPressed;
  final String? label;
  final bool attachedIcon;
  final Widget? container;
  final bool? autofocus;
  final double iconSize;
  final bool darkBackground;
  final double? fontSize;
  final MainAxisAlignment alignment;
  final IconPosition iconPosition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    Color overlayColor() {
      if (!enabled) {
        return theme.colorScheme.surface.withOpacity(0);
      }
      return extendedTheme.focusBg!;
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
        minimumSize: sizeCover ? Size(double.infinity, 54) : null,
        backgroundColor: color != null ? color : null,
      ),
      child: isLoading ? buildCircularProgress(context, theme) : child,
      onPressed: enabled ? onPressed : null,
    );

    Widget sufixButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: color != null ? color : null,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ))),
      child: isLoading ? buildCircularProgress(context, theme) : child,
      onPressed: enabled ? onPressed : null,
    );

    Widget secondaryButton = OutlinedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: sizeCover ? Size(double.infinity, 54) : null,
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
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
            ),
      onPressed: onPressed,
    );

    Widget textButtonHorizontalIcon = TextButton(
      child: Row(
          mainAxisAlignment: alignment,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconPosition == IconPosition.left ? icon : Container(),
            iconPosition == IconPosition.left
                ? SizedBox(width: 8)
                : Container(),
            Text(text,
                style: theme.textTheme.labelMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: boldText ? FontWeight.bold : FontWeight.normal,
                    color: color ?? null)),
            Padding(padding: EdgeInsets.only(left: 8)),
            iconPosition == IconPosition.right ? icon : Container(),
          ]),
      onPressed: onPressed,
    );

    Widget textButtonVerticalIcon = TextButton(
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
          style: TextStyle(
              fontFamily: theme.textTheme.bodyMedium?.fontFamily, fontSize: 14),
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
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  fixedSize: WidgetStateProperty.all(Size.zero),
                  foregroundColor: WidgetStateProperty.all(color),
                  overlayColor:
                      WidgetStateProperty.all(WitnetPallet.transparentWhite))
              : theme.textButtonTheme.style,
          child: Semantics(excludeSemantics: true, label: label, child: icon),
          onPressed: onPressed,
        ));

    Widget textButton = TextButton(
      style: color != null
          ? theme.textButtonTheme.style?.copyWith(
              foregroundColor: WidgetStateProperty.all(color),
              overlayColor:
                  WidgetStateProperty.all(WitnetPallet.transparentGrey))
          : theme.textButtonTheme.style,
      child: Text(
        text,
        style: color != null
            ? theme.textTheme.displaySmall?.copyWith(
                color: color,
                fontSize: fontSize,
                fontWeight: boldText ? FontWeight.bold : FontWeight.normal)
            : theme.textTheme.displaySmall?.copyWith(
                fontSize: fontSize,
                fontWeight: boldText ? FontWeight.bold : FontWeight.normal),
      ),
      onPressed: onPressed,
    );

    Widget stepBarButton = TextButton(
      style: theme.textButtonTheme.style!
          .copyWith(overlayColor: WidgetStateProperty.all(overlayColor())),
      child: Text(
        text,
        style: color != null
            ? theme.textTheme.labelMedium?.copyWith(
                fontSize: 16, fontWeight: FontWeight.w600, color: color)
            : theme.textTheme.labelMedium?.copyWith(fontSize: fontSize),
      ),
      onPressed: !enabled ? null : onPressed,
    );

    Widget containerButton = TextButton(
      autofocus: autofocus ?? false,
      style: theme.textButtonTheme.style?.copyWith(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: WidgetStateProperty.all(overlayColor())),
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
        case ButtonType.sufix:
          return sufixButton;
      }
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: padding,
      child: _getButtonByType(),
    );
  }
}
