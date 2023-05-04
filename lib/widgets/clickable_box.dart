import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';

typedef void StringCallback(String value);

enum ClickableBoxTheme {
  BorderColor,
  BgColor,
}

class ClickableBox extends StatelessWidget {
  final bool isSelected;
  final String? error;
  final List<Widget> content;
  final String value;
  final StringCallback onClick;

  const ClickableBox({
    required this.isSelected,
    required this.error,
    required this.value,
    required this.content,
    required this.onClick,
  });

  Map<ClickableBoxTheme, Color> errorTheme(ExtendedTheme theme) {
    return {
      ClickableBoxTheme.BorderColor: theme.errorColor!,
      ClickableBoxTheme.BgColor: theme.inactiveClickableBoxBgColor!,
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

  Map<ClickableBoxTheme, Color> localTheme(ExtendedTheme theme) {
    if (error != null) {
      return errorTheme(theme);
    }
    return isSelected ? selectedTheme(theme) : defaultTheme(theme);
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              child: Container(
                padding:
                    EdgeInsets.only(top: 14, bottom: 14, left: 16, right: 16),
                decoration: BoxDecoration(
                  color: localTheme(extendedTheme)[ClickableBoxTheme.BgColor],
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  border: Border.all(
                    color: localTheme(
                        extendedTheme)[ClickableBoxTheme.BorderColor]!,
                    width: 1,
                  ),
                ),
                margin: EdgeInsets.only(bottom: 8),
                child: Row(children: content),
              ),
              onTap: () {
                if (error == null) {
                  onClick(value);
                }
              })),
      if (error != null)
        Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(error!,
              style: theme.inputDecorationTheme.errorStyle
                  ?.copyWith(fontSize: 12)),
        ),
    ]);
  }
}
