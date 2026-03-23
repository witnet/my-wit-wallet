import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

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
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.push(
                      context,
                      CustomPageRoute(
                          builder: (BuildContext context) {
                            return originRoute;
                          },
                          maintainState: false,
                          settings: RouteSettings(name: originRouteName)))
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
