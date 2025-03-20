import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

const defaultIcon = Icon(null);

enum CustomBtnType {
  primary,
  secondary,
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
        semanticsLabel: localization.loading,
      ));
}

class CustomButton extends StatelessWidget {
  CustomButton({
    required this.padding,
    required this.text,
    required this.onPressed,
    this.type = CustomBtnType.primary,
    //
    this.enabled = true,
    // only when only text and icon
    this.attachedIcon = false,
    this.iconPosition = IconPosition.right,
    this.icon = defaultIcon,
    // primaryButton sufix sufixButton icon
    this.color,
    // primaryButton secondaryButton
    this.sizeCover = true,
    // primaryButton sufixButton secondaryButton smallButton
    this.isLoading = false,
  });

  final EdgeInsets padding;
  final bool sizeCover;
  final String text;
  final bool isLoading;
  final bool enabled;
  final CustomBtnType type;
  final VoidCallback onPressed;
  final Color? color;
  final Widget icon;
  final bool attachedIcon;
  final IconPosition iconPosition;

  Color overlayColor({Color? color = null, required ThemeData theme}) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    if (!enabled) {
      return theme.colorScheme.surface.withValues(alpha: 0);
    }
    return color ?? extendedTheme.focusBg!;
  }

  Widget getIconTextOrText() {
    bool positionLeft = iconPosition == IconPosition.left;
    bool positionRight = iconPosition == IconPosition.right;
    return attachedIcon
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                if (positionLeft) icon,
                Padding(
                  padding: EdgeInsets.only(
                      left: positionLeft ? 8 : 0, right: positionRight ? 8 : 0),
                  child: Text(text),
                ),
                if (positionRight) icon,
              ])
        : Text(text);
  }

  buildWithPadding({required Widget child}) {
    return Container(
      margin: EdgeInsets.zero,
      padding: padding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget primaryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: sizeCover ? Size(double.infinity, 54) : null,
        backgroundColor: color != null ? color : null,
      ),
      child: isLoading
          ? buildCircularProgress(context, theme)
          : getIconTextOrText(),
      onPressed: enabled ? onPressed : null,
    );

    Widget secondaryButton = OutlinedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: sizeCover ? Size(double.infinity, 54) : null,
      ),
      child: isLoading
          ? buildCircularProgress(context, theme)
          : getIconTextOrText(),
      onPressed: onPressed,
    );

    Widget _getButtonByType() {
      switch (type) {
        case CustomBtnType.primary:
          return primaryButton;
        case CustomBtnType.secondary:
          return secondaryButton;
      }
    }

    return buildWithPadding(child: _getButtonByType());
  }
}
