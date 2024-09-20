import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';

void buildNewAddressModal({
  required ThemeData theme,
  required BuildContext context,
  required String originRouteName,
  required Widget originRoute,
  required VoidCallback onAction,
  String iconName = 'general-warning',
}) {
  return buildAlertDialog(
      context: context,
      actions: [
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: localization.cancel,
            type: ButtonType.text,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(originRouteName)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                }),
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: localization.confirm,
            type: ButtonType.text,
            enabled: true,
            onPressed: onAction),
      ],
      icon: FontAwesomeIcons.circleExclamation,
      title: localization.generateAddressWarning,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(localization.generateAddressWarningMessage,
            style: theme.textTheme.bodyLarge),
        SizedBox(height: 16),
      ]));
}
