import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';

typedef void StringCallback(String value);

enum ClickableBoxTheme {
  BorderColor,
  BgColor,
}

enum ClickableBoxStatus { Default, Selected, Disabled }

class ClickableBox extends StatelessWidget {
  final bool isSelected;
  final String? error;
  final List<Widget> content;
  final String value;
  final String? label;
  final StringCallback onClick;

  const ClickableBox({
    required this.isSelected,
    required this.error,
    required this.value,
    required this.content,
    required this.onClick,
    this.label,
  });

  Map<ClickableBoxTheme, Color> disabledTheme(ExtendedTheme theme) {
    return {
      ClickableBoxTheme.BorderColor:
          theme.inactiveClickableBoxBorderColor!.withOpacity(0.5),
      ClickableBoxTheme.BgColor:
          theme.inactiveClickableBoxBgColor!.withOpacity(0.5),
    };
  }

  Map<ClickableBoxTheme, Color> selectedTheme(ExtendedTheme theme) {
    return {
      ClickableBoxTheme.BorderColor: theme.activeClickableBoxBorderColor!,
      ClickableBoxTheme.BgColor: theme.activeClickableBoxBgColor!,
    };
  }

  Map<ClickableBoxTheme, Color> defaultTheme(ExtendedTheme theme) {
    return {
      ClickableBoxTheme.BgColor: theme.inactiveClickableBoxBgColor!,
      ClickableBoxTheme.BorderColor: theme.inactiveClickableBoxBorderColor!,
    };
  }

  ClickableBoxStatus get buttonState {
    if (error != null) {
      return ClickableBoxStatus.Disabled;
    }
    if (isSelected) {
      return ClickableBoxStatus.Selected;
    } else {
      return ClickableBoxStatus.Default;
    }
  }

  Map<ClickableBoxTheme, Color> localTheme(ExtendedTheme theme) {
    if (buttonState == ClickableBoxStatus.Disabled) {
      return disabledTheme(theme);
    }
    return buttonState == ClickableBoxStatus.Selected
        ? selectedTheme(theme)
        : defaultTheme(theme);
  }

  Widget buildPaddedBoxButton(ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PaddedButton(
        padding: EdgeInsets.zero,
        enabled: error == null,
        autofocus: isSelected,
        label: label,
        text: 'wallet',
        type: ButtonType.boxButton,
        onPressed: () => {
          if (error == null) {onClick(value)}
        },
        container: Container(
          padding: EdgeInsets.only(top: 14, bottom: 14, left: 16, right: 16),
          decoration: BoxDecoration(
            color: localTheme(extendedTheme)[ClickableBoxTheme.BgColor],
            borderRadius: BorderRadius.all(extendedTheme.borderRadius!),
            border: Border.all(
              color: localTheme(extendedTheme)[ClickableBoxTheme.BorderColor]!,
              width: 1,
            ),
          ),
          margin: EdgeInsets.all(8),
          child: buttonState == ClickableBoxStatus.Disabled
              ? Opacity(opacity: 0.5, child: Row(children: content))
              : Row(children: content),
        ),
      ),
    ]);
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return buildPaddedBoxButton(theme);
  }
}
