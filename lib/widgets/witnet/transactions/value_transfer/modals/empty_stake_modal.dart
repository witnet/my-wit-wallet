import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildEmptyStakeModal({
  required ThemeData theme,
  required BuildContext context,
  String iconName = 'empty',
  required void Function() onPressedStake,
  required void Function() onPressedCancel,
}) {
  return buildAlertDialog(
      context: context,
      actions: [
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: localization.close,
            sizeCover: false,
            type: ButtonType.primary,
            enabled: true,
            onPressed: onPressedCancel),
        PaddedButton(
          padding: EdgeInsets.all(8),
          text: localization.stake,
          type: ButtonType.text,
          enabled: true,
          onPressed: onPressedStake,
        )
      ],
      title: localization.emptyStakeTitle,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: iconName, height: 100),
        SizedBox(height: 16),
        Text(localization.emptyStakeMessage, style: theme.textTheme.bodyLarge),
        SizedBox(height: 16),
      ]));
}
