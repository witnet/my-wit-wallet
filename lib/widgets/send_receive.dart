import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:flutter/material.dart';

typedef void VoidCallback();

class SendReceiveButtons extends StatelessWidget {
  SendReceiveButtons({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    Future<void> _showCreateVTTDialog() async {
      BlocProvider.of<TransactionBloc>(context).add(ResetTransactionEvent());
      Navigator.push(
          context,
          CustomPageRoute(
              builder: (BuildContext context) {
                return CreateVttScreen();
              },
              maintainState: false,
              settings: RouteSettings(name: CreateVttScreen.route)));
    }

    Future<void> _showReceiveDialog() async {
      BlocProvider.of<TransactionBloc>(context).add(ResetTransactionEvent());
      Navigator.push(
          context,
          CustomPageRoute(
              builder: (BuildContext context) {
                return ReceiveTransactionScreen();
              },
              maintainState: false,
              settings: RouteSettings(name: ReceiveTransactionScreen.route)));
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          PaddedButton(
            color: extendedTheme.mediumPanelText!.color,
            boldText: true,
            padding: EdgeInsets.only(left: 16, right: 16),
            text: localization.send,
            onPressed: currentRoute(context) != CreateVttScreen.route
                ? _showCreateVTTDialog
                : () {},
            icon: Container(
                height: 40,
                child: svgThemeImage(theme, name: 'send-icon', height: 18)),
            type: ButtonType.horizontalIcon,
            alignment: MainAxisAlignment.start,
            iconPosition: IconPosition.left,
          ),
          SizedBox(width: 16),
          PaddedButton(
            color: extendedTheme.mediumPanelText!.color,
            boldText: true,
            padding: EdgeInsets.only(left: 16, right: 16),
            text: localization.receive,
            onPressed: currentRoute != ReceiveTransactionScreen.route
                ? _showReceiveDialog
                : () {},
            icon: Container(
                height: 40,
                child: svgThemeImage(theme, name: 'receive-icon', height: 18)),
            type: ButtonType.horizontalIcon,
            alignment: MainAxisAlignment.start,
            iconPosition: IconPosition.left,
          ),
        ]);
  }
}
