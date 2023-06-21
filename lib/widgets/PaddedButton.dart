import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

const defaultIcon = Icon(null);

class PaddedButton extends StatelessWidget {
  PaddedButton({
    required this.padding,
    required this.text,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.icon = defaultIcon,
    this.enabled = true,
    required this.type,
    this.label,
  });

  final EdgeInsets padding;
  final String text;
  final bool isLoading;
  final bool enabled;
  final Color? color;
  final String type;
  final Widget icon;
  final VoidCallback onPressed;
  final String? label;

  Widget _buildCircularProgress(context, theme) {
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

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == 'primary';
    final isText = type == 'text';
    final hasHorizontalIcon = type == 'horizontal-icon';
    final hasVerticalIcon = type == 'vertical-icon';
    final isIconButton = type == 'icon-button';
    final isStepBarButton = type == 'stepbar';
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    Widget primaryButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: isLoading ? _buildCircularProgress(context, theme) : Text(text),
      onPressed: enabled ? onPressed : null,
    );

    Widget secondaryButton = OutlinedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, 54),
      ),
      child: isLoading ? _buildCircularProgress(context, theme) : Text(text),
      onPressed: onPressed,
    );

    Widget textButtonHorizontalIcon = TextButton(
      child: Row(children: [
        Text(
          text,
          style: TextStyle(fontFamily: 'Almarai', fontSize: 14),
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
                  MaterialStateProperty.all(Color.fromARGB(16, 255, 255, 255)))
          : theme.textButtonTheme.style,
      child: Column(children: [
        icon,
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(fontFamily: 'Almarai', fontSize: 14),
        ),
      ]),
      onPressed: onPressed,
    );

    Widget iconButton = Semantics(
        label: label,
        button: true,
        child: TextButton(
          style: color != null
              ? theme.textButtonTheme.style?.copyWith(
                  foregroundColor: MaterialStateProperty.all(color),
                  overlayColor: MaterialStateProperty.all(
                      Color.fromARGB(16, 255, 255, 255)))
              : theme.textButtonTheme.style,
          child: icon,
          onPressed: onPressed,
        ));

    Widget textButton = TextButton(
      style: color != null
          ? theme.textButtonTheme.style?.copyWith(
              foregroundColor: MaterialStateProperty.all(color),
              overlayColor:
                  MaterialStateProperty.all(Color.fromARGB(16, 255, 255, 255)))
          : theme.textButtonTheme.style,
      child: Text(
        text,
        style: color != null
            ? theme.textTheme.labelMedium?.copyWith(color: color)
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
      } else {
        return secondaryButton;
      }
    }

    return Container(
      margin: padding,
      child: _getButtonByType(),
    );
  }
}
