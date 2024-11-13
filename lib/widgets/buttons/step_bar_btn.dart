import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

class StepBarBtn extends CustomButton {
  StepBarBtn({
    required super.text,
    required super.padding,
    required super.onPressed,
    required this.label,
    this.autofocus = false,
    super.enabled,
    this.active = true,
  });

  final bool active;
  final String label;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;

    Color getStepTabColor() {
      if (autofocus) {
        return extendedTheme.stepBarActiveColor!;
      }
      if (enabled) {
        return extendedTheme.stepBarActionableColor!;
      } else {
        return extendedTheme.stepBarColor!;
      }
    }

    return super.buildWithPadding(
        child: TextButton(
      autofocus: autofocus,
      style: theme.textButtonTheme.style?.copyWith(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          overlayColor: WidgetStateProperty.all(WitnetPallet.transparent)),
      child: Semantics(
          label: label,
          excludeSemantics: true,
          child: Container(
            width: 110,
            padding: EdgeInsets.only(top: 8, bottom: 8, left: 0, right: 0),
            decoration: BoxDecoration(
              color: WitnetPallet.transparent,
              border: Border(
                top: BorderSide(color: getStepTabColor(), width: 2),
              ),
            ),
            margin: EdgeInsets.all(8),
            child: Text(
              text,
              style: enabled
                  ? theme.textTheme.titleMedium!
                      .copyWith(color: getStepTabColor())
                  : theme.textTheme.titleMedium!
                      .copyWith(color: getStepTabColor()),
            ),
          )),
      onPressed: enabled ? onPressed : null,
    ));
  }
}
