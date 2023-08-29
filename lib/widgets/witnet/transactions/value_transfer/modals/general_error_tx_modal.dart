import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

void buildTxGeneralExceptionModal(
    {required ThemeData theme,
    required BuildContext context,
    required VoidCallback onAction}) {
  return buildAlertDialog(
      context: context,
      actions: [
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: 'Cancel',
            type: ButtonType.text,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(CreateVttScreen.route)),
                  ScaffoldMessenger.of(context).clearSnackBars(),
                  Navigator.pushReplacement(
                      context,
                      CustomPageRoute(
                          builder: (BuildContext context) {
                            return DashboardScreen();
                          },
                          maintainState: false,
                          settings: RouteSettings(name: DashboardScreen.route)))
                }),
        PaddedButton(
            padding: EdgeInsets.all(8),
            text: 'Try again!',
            type: ButtonType.text,
            enabled: true,
            onPressed: () => {
                  Navigator.popUntil(
                      context, ModalRoute.withName(CreateVttScreen.route)),
                  onAction(),
                })
      ],
      icon: FontAwesomeIcons.circleExclamation,
      title: 'Error',
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        svgThemeImage(theme, name: 'transaction-error', height: 100),
        SizedBox(height: 16),
        Text('Error sending the transaction, try again!',
            style: theme.textTheme.bodyLarge)
      ]));
}
