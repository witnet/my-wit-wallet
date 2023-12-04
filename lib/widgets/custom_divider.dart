import 'package:flutter/material.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider();

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(
      children: [
        Divider(
          thickness: 0.5,
          indent: 0,
          endIndent: 0,
          color: extendedTheme.txBorderColor!,
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
