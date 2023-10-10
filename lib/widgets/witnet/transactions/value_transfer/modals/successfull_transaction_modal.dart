import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

void buildSuccessfullTransaction(
    ThemeData theme, VTTCreateState state, BuildContext context) {
  AppLocalizations _localization = AppLocalizations.of(context)!;
  return buildAlertDialog(
    context: context,
    actions: [
      PaddedButton(
          padding: EdgeInsets.all(8),
          text: _localization.close,
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
              })
    ],
    title: _localization.txnSuccess,
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      svgThemeImage(theme, name: 'transaction-success', height: 100),
      SizedBox(height: 16),
      InfoElement(
        plainText: true,
        label: _localization.txnCheckStatus,
        text: state.vtTransaction.transactionID,
        url:
            'https://witnet.network/search/${state.vtTransaction.transactionID}',
      )
    ]),
  );
}
