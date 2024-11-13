import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

class ContainerBtn extends CustomButton {
  ContainerBtn({
    required super.text,
    required super.padding,
    required super.onPressed,
    super.enabled,
    this.autofocus = false,
    required this.label,
    required this.container,
  });

  final Widget container;
  final String label;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return super.buildWithPadding(
        child: TextButton(
      autofocus: autofocus,
      style: theme.textButtonTheme.style?.copyWith(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: WidgetStateProperty.all(overlayColor(theme: theme))),
      child: Semantics(label: label, excludeSemantics: true, child: container),
      onPressed: !enabled ? null : onPressed,
    ));
  }
}
