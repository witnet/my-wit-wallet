import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/receive_transaction/receive_tx_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/util/current_route.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/get_navigation_color.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

typedef void VoidCallback();

class SendReceiveButtons extends StatelessWidget {
  SendReceiveButtons({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    Future<void> _showCreateVTTDialog() async {
      BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
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
      BlocProvider.of<VTTCreateBloc>(context).add(ResetTransactionEvent());
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
            padding: EdgeInsets.zero,
            text: localization.send,
            onPressed: currentRoute(context) != CreateVttScreen.route
                ? _showCreateVTTDialog
                : () {},
            icon: Container(
                height: 40,
                child: Icon(
                  FontAwesomeIcons.locationArrow,
                  size: 18,
                )),
            type: ButtonType.horizontalIcon,
            alignment: MainAxisAlignment.start,
            iconPosition: IconPosition.left,
          ),
          SizedBox(width: 16),
          PaddedButton(
            color: getNavigationColor(
                route: ReceiveTransactionScreen.route, context: context),
            padding: EdgeInsets.zero,
            text: localization.receive,
            onPressed: currentRoute != ReceiveTransactionScreen.route
                ? _showReceiveDialog
                : () {},
            icon: Container(
                height: 40,
                child: Transform.rotate(
                    angle: 90 * math.pi / 90,
                    child: Icon(
                      FontAwesomeIcons.locationArrow,
                      size: 18,
                    ))),
            type: ButtonType.horizontalIcon,
            alignment: MainAxisAlignment.start,
            iconPosition: IconPosition.left,
          ),
        ]);
  }
}
