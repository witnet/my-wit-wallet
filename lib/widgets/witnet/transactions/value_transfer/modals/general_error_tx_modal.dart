import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

void buildTxGeneralExceptionModal({
  required ThemeData theme,
  required BuildContext context,
  required VoidCallback onAction,
  required String originRoute,
}) {
  return buildAlertDialog(
      context: context,
      actions: [
        CustomButton(
            padding: EdgeInsets.all(8),
            text: localization.cancel,
            type: CustomBtnType.secondary,
            sizeCover: false,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(context, ModalRoute.withName(originRoute)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.pushReplacementNamed(context, originRoute)
                }),
        CustomButton(
            padding: EdgeInsets.zero,
            sizeCover: false,
            text: localization.tryAgain,
            type: CustomBtnType.primary,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(context, ModalRoute.withName(originRoute)),
                  onAction(),
                })
      ],
      image: svgThemeImage(theme, name: 'transaction-error', height: 100),
      title: localization.error,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(localization.errorTransaction, style: theme.textTheme.bodyLarge)
      ]));
}
