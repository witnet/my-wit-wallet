import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/sending_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/signing_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/successfull_transaction_modal.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/screens/send_transaction/send_vtt_screen.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';

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
    int fee = BlocProvider.of<VTTCreateBloc>(context).getFee();
    return BlocBuilder<VTTCreateBloc, VTTCreateState>(
      builder: (context, state) {
        if (state.vttCreateStatus == VTTCreateStatus.discarded) {
          buildTxGeneralExceptionModal(
              theme: theme,
              context: context,
              onAction: () => _sendTransaction(state.vtTransaction));
        } else if (state.vttCreateStatus == VTTCreateStatus.signing) {
          Navigator.popUntil(
              context, ModalRoute.withName(CreateVttScreen.route));
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
                onAction: () => _sendTransaction(state.vtTransaction));
          }
        } else if (state.vttCreateStatus == VTTCreateStatus.sending) {
          Navigator.popUntil(
              context, ModalRoute.withName(CreateVttScreen.route));
          buildSendingTransactionModal(theme, context);
        } else if (state.vttCreateStatus == VTTCreateStatus.accepted) {
          buildSuccessfullTransaction(theme, state, context);
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
              InfoElement(
                label: 'Amount',
                text:
                    '${state.vtTransaction.body.outputs.first.value.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
              ),
              InfoElement(
                  label: 'Fee',
                  isLastItem: true,
                  text:
                      '${fee.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
            ]));
      },
    );
  }
}
