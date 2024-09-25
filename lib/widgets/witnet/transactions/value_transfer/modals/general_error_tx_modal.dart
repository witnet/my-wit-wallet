import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildTxGeneralExceptionModal({
  required ThemeData theme,
  required BuildContext context,
  required VoidCallback onAction,
  required String originRoute,
}) {
  return buildAlertDialog(
      context: context,
      actions: [
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: localization.cancel,
            type: ButtonType.secondary,
            sizeCover: false,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(context, ModalRoute.withName(originRoute)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.pushReplacementNamed(context, originRoute)
                }),
        PaddedButton(
            padding: EdgeInsets.zero,
            sizeCover: false,
            text: localization.tryAgain,
            type: ButtonType.primary,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(context, ModalRoute.withName(originRoute)),
                  onAction(),
                })
      ],
      icon: FontAwesomeIcons.circleExclamation,
      title: localization.error,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: 16),
        svgThemeImage(theme, name: 'transaction-error', height: 100),
        SizedBox(height: 16),
        Text(localization.errorTransaction, style: theme.textTheme.bodyLarge)
      ]));
}
