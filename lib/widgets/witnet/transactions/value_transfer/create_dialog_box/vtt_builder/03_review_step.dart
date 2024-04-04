import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_wit_wallet/util/allow_biometrics.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/sending_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/signing_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/successfull_transaction_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/unlock_keychain_modal.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

typedef void VoidCallback(bool value);

class ReviewStep extends StatefulWidget {
  final Function nextAction;
  final Wallet currentWallet;
  final String originRoute;
  final GeneralTransaction? speedUpTx;
  ReviewStep({
    required this.nextAction,
    required this.currentWallet,
    required this.originRoute,
    this.speedUpTx,
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
    BlocProvider.of<VTTCreateBloc>(context).add(SetBuildingEvent());
    // Sign transaction
    if (await showBiometrics()) {
      BlocProvider.of<VTTCreateBloc>(context).add(ShowAuthPreferencesEvent());
    } else {
      _signTransaction();
    }
  }

  void _signTransaction() {
    final vtt =
        BlocProvider.of<VTTCreateBloc>(context).state.vtTransaction.body;
    BlocProvider.of<VTTCreateBloc>(context).add(SignTransactionEvent(
      currentWallet: widget.currentWallet,
      vtTransactionBody: vtt,
      speedUpTx: widget.speedUpTx,
    ));
  }

  void _sendTransaction(VTTransaction vtTransaction) {
    BlocProvider.of<VTTCreateBloc>(context).add(SendTransactionEvent(
        currentWallet: widget.currentWallet,
        transaction: vtTransaction,
        speedUpTx: widget.speedUpTx));
  }

  NavAction next() {
    return NavAction(
      label: localization.signAndSend,
      action: nextAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int fee = BlocProvider.of<VTTCreateBloc>(context).getFee();
    return BlocListener<VTTCreateBloc, VTTCreateState>(
        listenWhen: (VTTCreateState prevState, VTTCreateState state) => true,
        listener: (context, state) {
          if (state.vttCreateStatus == VTTCreateStatus.needPasswordValidation) {
            unlockKeychainModal(
                title: localization.enterYourPassword,
                imageName: 'signing-transaction',
                theme: theme,
                context: context,
                onAction: () => _signTransaction(),
                routeToRedirect: widget.originRoute);
          }
          if (state.vttCreateStatus == VTTCreateStatus.discarded) {
            buildTxGeneralExceptionModal(
                theme: theme,
                context: context,
                originRoute: widget.originRoute,
                onAction: () => _sendTransaction(state.vtTransaction));
          } else if (state.vttCreateStatus == VTTCreateStatus.signing) {
            Navigator.popUntil(
                context, ModalRoute.withName(widget.originRoute));
            buildSigningTxModal(theme, context);
          } else if (state.vttCreateStatus == VTTCreateStatus.finished) {
            // Validate vtt weight to ensure confirmation
            if (state.vtTransaction.weight <= MAX_VT_WEIGHT) {
              // Send transaction after signed
              _sendTransaction(state.vtTransaction);
            } else {
              buildTxGeneralExceptionModal(
                  theme: theme,
                  context: context,
                  originRoute: widget.originRoute,
                  onAction: () => _sendTransaction(state.vtTransaction));
            }
          } else if (state.vttCreateStatus == VTTCreateStatus.sending) {
            Navigator.popUntil(
                context, ModalRoute.withName(widget.originRoute));
            buildSendingTransactionModal(theme, context);
          } else if (state.vttCreateStatus == VTTCreateStatus.accepted) {
            buildSuccessfullTransaction(
                theme, state, context, widget.originRoute);
          }
        },
        child: BlocBuilder<VTTCreateBloc, VTTCreateState>(
          builder: (context, state) {
            bool timelockSet =
                state.vtTransaction.body.outputs[0].timeLock != 0;
            return Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.txnDetails,
                        style: theme.textTheme.displaySmall,
                      ),
                      SizedBox(height: 24),
                      InfoElement(
                          label: localization.to,
                          text: state
                              .vtTransaction.body.outputs.first.pkh.address),
                      InfoElement(
                        label: localization.amount,
                        text:
                            '${state.vtTransaction.body.outputs.first.value.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                      ),
                      _timelock(state),
                      if (timelockSet)
                        SizedBox(
                          height: 16,
                        ),
                      InfoElement(
                          label: localization.fee,
                          isLastItem: true,
                          text:
                              '${fee.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
                      SizedBox(height: 16),
                    ]));
          },
        ));
  }
}

Widget _timelock(state) {
  if (state.vtTransaction.body.outputs[0].timeLock != 0) {
    int timestamp = state.vtTransaction.body.outputs[0].timeLock.toInt() * 1000;
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return InfoElement(
        label: localization.timelock,
        isLastItem: true,
        text: '${DateFormat("h:mm a E, MMM dd yyyy ").format(dateTime)}');
  }
  return SizedBox(
    height: 0,
  );
}
