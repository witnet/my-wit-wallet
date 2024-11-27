import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/stake/stake_screen.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

void buildEmptyStakeModal({
  required ThemeData theme,
  required BuildContext context,
  required String originRouteName,
  bool allowStake = true,
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
            type: allowStake ? CustomBtnType.secondary : CustomBtnType.primary,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(originRouteName)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                }),
        allowStake
            ? CustomButton(
                padding: EdgeInsets.zero,
                text: localization.stake,
                sizeCover: false,
                type: CustomBtnType.primary,
                enabled: true,
                onPressed: () => {
                      Navigator.push(
                          context,
                          CustomPageRoute(
                              builder: (BuildContext context) {
                                return StakeScreen();
                              },
                              maintainState: false,
                              settings:
                                  RouteSettings(name: StakeScreen.route))),
                      ScaffoldMessenger.of(context).clearSnackBars(),
                    })
            : Container(),
      ],
      image: Container(
          width: 100, height: 100, child: svgImage(name: iconName, height: 50)),
      title: localization.emptyStakeTitle,
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(localization.emptyStakeMessage, style: theme.textTheme.bodyLarge),
      ]));
}
