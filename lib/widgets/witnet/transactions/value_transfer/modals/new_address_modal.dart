import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

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
        CustomButton(
            padding: EdgeInsets.zero,
            text: localization.cancel,
            sizeCover: false,
            type: CustomBtnType.secondary,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(originRouteName)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                }),
        CustomButton(
            padding: EdgeInsets.zero,
            text: localization.confirm,
            sizeCover: false,
            type: CustomBtnType.primary,
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
