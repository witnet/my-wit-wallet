import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';

void buildDisableStakeModal({
  required ThemeData theme,
  required BuildContext context,
  required String originRouteName,
  required Widget originRoute,
  String iconName = 'empty',
}) {
  return buildAlertDialog(
      context: context,
      actions: [
        CustomButton(
            padding: EdgeInsets.zero,
            text: localization.close,
            sizeCover: false,
            type: CustomBtnType.primary,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(originRouteName)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                }),
      ],
      image: Container(
          width: 100, height: 100, child: svgImage(name: iconName, height: 50)),
      title: localization.disableStakeTitle,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(localization.disableStakeMessage,
            style: theme.textTheme.bodyLarge),
      ]));
}
