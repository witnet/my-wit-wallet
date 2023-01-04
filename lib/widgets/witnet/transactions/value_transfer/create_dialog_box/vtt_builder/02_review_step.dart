import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/nav_action.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/alert_dialog.dart';
import 'package:witnet_wallet/widgets/info_element.dart';
import 'package:witnet_wallet/util/extensions/num_extensions.dart';

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

  void nextAction() async {
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
      label: 'Sign and Send',
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
                    type: 'text',
                    enabled: true,
                    onPressed: () => {
                          Navigator.pushReplacementNamed(
                              context, DashboardScreen.route)
                        }),
                PaddedButton(
                    padding: EdgeInsets.all(8),
                    text: 'Try again!',
                    type: 'text',
                    enabled: true,
                    onPressed: () => {
                          Navigator.pushReplacementNamed(
                              context, CreateVttScreen.route)
                        })
              ],
              icon: FontAwesomeIcons.circleExclamation,
              title: 'Error',
              content: Text('Error sending the transaction, try again!',
                  style: theme.textTheme.bodyText1));
        } else if (state.vttCreateStatus == VTTCreateStatus.signing) {
          buildAlertDialog(
              context: context,
              actions: [],
              icon: FontAwesomeIcons.fileSignature,
              title: 'Signing transaction',
              content: Text('The transaction is being signed',
                  style: theme.textTheme.bodyText1));
        } else if (state.vttCreateStatus == VTTCreateStatus.finished) {
          // Send transaction after signed
          _sendTransaction(state.vtTransaction);
        } else if (state.vttCreateStatus == VTTCreateStatus.sending) {
          buildAlertDialog(
              context: context,
              actions: [],
              icon: FontAwesomeIcons.paperPlane,
              title: 'Sending transaction',
              content: Text('The transaction is being send',
                  style: theme.textTheme.bodyText1));
        } else if (state.vttCreateStatus == VTTCreateStatus.accepted) {
          buildAlertDialog(
            context: context,
            actions: [
              PaddedButton(
                  padding: EdgeInsets.all(8),
                  text: 'Ok!',
                  type: 'text',
                  enabled: true,
                  onPressed: () => {
                        Navigator.pushReplacementNamed(
                            context, DashboardScreen.route)
                      })
            ],
            icon: FontAwesomeIcons.check,
            title: 'Transaction succesfully sent!',
            content: Column(mainAxisSize: MainAxisSize.min, children: [
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
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Transaction details',
            style: theme.textTheme.headline3,
          ),
          SizedBox(height: 24),
          InfoElement(
              label: 'To',
              text: state.vtTransaction.body.outputs.first.pkh.address),
          SizedBox(height: 16),
          InfoElement(
            label: 'Amount',
            text:
                '${state.vtTransaction.body.outputs.first.value.standardizeWitUnits()} Wit',
          ),
          SizedBox(height: 16),
          InfoElement(label: 'Fee', text: '${fee.standardizeWitUnits()} Wit'),
          SizedBox(height: 24),
        ]);
      },
    );
  }
}
