import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

class TapBarBtn extends CustomButton {
  TapBarBtn({
    required super.text,
    required super.padding,
    required super.onPressed,
    super.attachedIcon,
    super.iconPosition,
    required this.label,
    this.active = false,
    this.enabled = true,
  });

  final bool enabled;
  final bool active;
  final String label;

  Widget buildTabBarBtn(ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return active
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
                shadowColor: Colors.transparent,
                elevation: 0,
                overlayColor: super.overlayColor(
                    theme: theme,
                    color: extendedTheme.backgroundBox!.withOpacity(0.5)),
                minimumSize: null,
                textStyle: theme.textTheme.titleMedium),
            child: super.getIconTextOrText(),
            onPressed: enabled ? onPressed : null,
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: extendedTheme.backgroundBox,
                foregroundColor: theme.textTheme.bodyMedium!.color,
                splashFactory: NoSplash.splashFactory,
                shadowColor: Colors.transparent,
                elevation: 0,
                overlayColor: overlayColor(
                    theme: theme,
                    color: extendedTheme.backgroundBox!.withOpacity(0.5)),
                minimumSize: null,
                textStyle: theme.textTheme.titleMedium),
            child: getIconTextOrText(),
            onPressed: enabled ? onPressed : null,
          );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return super.buildWithPadding(child: buildTabBarBtn(theme));
  }
}
