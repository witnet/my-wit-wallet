import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/alert_dialog.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';

typedef void VoidCallback(bool value);

class ReviewStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  ReviewStep({
    required this.nextAction,
    required this.currentWallet,
  });

  @override
  State<StatefulWidget> createState() => ReviewStepState();
}

class ReviewStepState extends State<ReviewStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.nextAction(next));
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void nextAction() {
    // Sign transaction
    final vtt =
        BlocProvider.of<VTTCreateBloc>(context).state.vtTransaction.body;
    BlocProvider.of<VTTCreateBloc>(context).add(SignTransactionEvent(
        currentWallet: widget.currentWallet, vtTransactionBody: vtt));
  }

  void _sendTransaction(VTTransaction vtTransaction) {
    BlocProvider.of<VTTCreateBloc>(context).add(SendTransactionEvent(
        currentWallet: widget.currentWallet, transaction: vtTransaction));
  }

  NavAction next() {
    return NavAction(
      label: 'Sign and send',
      action: nextAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int fee = BlocProvider.of<VTTCreateBloc>(context).feeNanoWit;
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
      builder: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.exception) {
          buildAlertDialog(
              context: context,
              actions: [
                PaddedButton(
                    padding: EdgeInsets.all(8),
                    text: 'Cancel',
                    type: ButtonType.text,
                    enabled: true,
                    onPressed: () => {
                          Navigator.popUntil(context,
                              ModalRoute.withName(CreateVttScreen.route)),
                          Navigator.pushReplacement(
                              context,
                              CustomPageRoute(
                                  builder: (BuildContext context) {
                                    return DashboardScreen();
                                  },
                                  maintainState: false,
                                  settings: RouteSettings(
                                      name: DashboardScreen.route)))
                        }),
                PaddedButton(
                    padding: EdgeInsets.all(8),
                    text: 'Try again!',
                    type: ButtonType.text,
                    enabled: true,
                    onPressed: () => {
                          Navigator.popUntil(context,
                              ModalRoute.withName(CreateVttScreen.route)),
                          _sendTransaction(state.vtTransaction),
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
        } else if (state.vttCreateStatus == VTTCreateStatus.signing) {
          Navigator.popUntil(
              context, ModalRoute.withName(CreateVttScreen.route));
          buildAlertDialog(
              context: context,
              actions: [],
              title: 'Signing transaction',
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                svgThemeImage(theme, name: 'signing-transaction', height: 100),
                SizedBox(height: 16),
                Text('The transaction is being signed',
                    style: theme.textTheme.bodyLarge)
              ]));
        } else if (state.vttCreateStatus == VTTCreateStatus.finished) {
          // Send transaction after signed
          _sendTransaction(state.vtTransaction);
        } else if (state.vttCreateStatus == VTTCreateStatus.sending) {
          Navigator.popUntil(
              context, ModalRoute.withName(CreateVttScreen.route));
          buildAlertDialog(
              context: context,
              actions: [],
              title: 'Sending transaction',
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                svgThemeImage(theme, name: 'sending-transaction', height: 100),
                SizedBox(height: 16),
                Text('The transaction is being sent',
                    style: theme.textTheme.bodyLarge)
              ]));
        } else if (state.vttCreateStatus == VTTCreateStatus.accepted) {
          buildAlertDialog(
            context: context,
            actions: [
              PaddedButton(
                  padding: EdgeInsets.all(8),
                  text: 'Close',
                  type: ButtonType.text,
                  enabled: true,
                  onPressed: () => {
                        Navigator.popUntil(context,
                            ModalRoute.withName(CreateVttScreen.route)),
                        Navigator.pushReplacement(
                            context,
                            CustomPageRoute(
                                builder: (BuildContext context) {
                                  return DashboardScreen();
                                },
                                maintainState: false,
                                settings:
                                    RouteSettings(name: DashboardScreen.route)))
                      })
            ],
            title: 'Transaction succesfully sent!',
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              svgThemeImage(theme, name: 'transaction-success', height: 100),
              SizedBox(height: 16),
              InfoElement(
                plainText: true,
                label:
                    'Check the transaction status in the Witnet Block Explorer:',
                text: state.vtTransaction.transactionID,
                url:
                    'https://witnet.network/search/${state.vtTransaction.transactionID}',
              )
            ]),
          );
        }
        return Padding(
            padding: EdgeInsets.only(left: 8, right: 8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Transaction details',
                style: theme.textTheme.displaySmall,
              ),
              SizedBox(height: 24),
              InfoElement(
                  label: 'To',
                  text: state.vtTransaction.body.outputs.first.pkh.address),
              SizedBox(height: 16),
              InfoElement(
                label: 'Amount',
                text:
                    '${state.vtTransaction.body.outputs.first.value.toInt().standardizeWitUnits()} ${WIT_UNIT[WitUnit.Wit]}',
              ),
              SizedBox(height: 16),
              InfoElement(
                  label: 'Fee',
                  text:
                      '${fee.standardizeWitUnits()} ${WIT_UNIT[WitUnit.Wit]}'),
            ]));
      },
    );
  }
}
