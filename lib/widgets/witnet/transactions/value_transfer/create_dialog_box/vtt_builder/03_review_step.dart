import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_wit_wallet/util/allow_biometrics.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/widgets/layouts/send_transaction_layout.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/sending_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/signing_tx_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/successfull_transaction_modal.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/unlock_keychain_modal.dart';
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
  final TransactionType transactionType;
  ReviewStep({
    required this.nextAction,
    required this.currentWallet,
    required this.originRoute,
    required this.transactionType,
    this.speedUpTx,
  });

  @override
  State<StatefulWidget> createState() => ReviewStepState();
}

class ReviewStepState extends State<ReviewStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  bool get showFeeInfo => widget.transactionType != TransactionType.Unstake;
  bool get isVttTransaction => widget.transactionType == TransactionType.Vtt;
  TransactionBloc get createVttBloc =>
      BlocProvider.of<TransactionBloc>(context);

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
    BlocProvider.of<TransactionBloc>(context).add(SetBuildingEvent());
    // Sign transaction
    if (await showBiometrics()) {
      BlocProvider.of<TransactionBloc>(context).add(ShowAuthPreferencesEvent());
    } else {
      _signTransaction();
    }
  }

  void _signTransaction() {
    final vttBody = createVttBloc.state.transaction
        .getBody(createVttBloc.state.transactionType);
    BlocProvider.of<TransactionBloc>(context).add(SignTransactionEvent(
      currentWallet: widget.currentWallet,
      transactionBody: vttBody,
      speedUpTx: widget.speedUpTx,
    ));
  }

  void _sendTransaction(BuildTransaction transaction) {
    BlocProvider.of<TransactionBloc>(context).add(SendTransactionEvent(
        currentWallet: widget.currentWallet,
        transaction: transaction,
        speedUpTx: widget.speedUpTx));
  }

  NavAction next() {
    return NavAction(
      label: localization.signAndSend,
      action: nextAction,
    );
  }

  String getAmountValue(TransactionState state) {
    return '${state.transaction.getAmount(state.transactionType)} ${WIT_UNIT[WitUnit.Wit]}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<TransactionBloc, TransactionState>(
        listenWhen: (TransactionState prevState, TransactionState state) =>
            true,
        listener: (context, state) {
          if (state.transactionStatus ==
              TransactionStatus.needPasswordValidation) {
            unlockKeychainModal(
                title: localization.enterYourPassword,
                imageName: 'signing-transaction',
                theme: theme,
                context: context,
                onAction: () => _signTransaction(),
                routeToRedirect: widget.originRoute);
          }
          if (state.transactionStatus == TransactionStatus.discarded) {
            buildTxGeneralExceptionModal(
                theme: theme,
                context: context,
                originRoute: widget.originRoute,
                onAction: () => _sendTransaction(state.transaction));
          } else if (state.transactionStatus == TransactionStatus.signing) {
            Navigator.popUntil(
                context, ModalRoute.withName(widget.originRoute));
            buildSigningTxModal(theme, context);
          } else if (state.transactionStatus == TransactionStatus.finished) {
            // Validate vtt weight to ensure confirmation
            if (state.transaction.get(state.transactionType) != null &&
                state.transaction.getWeight(state.transactionType) <=
                    MAX_VT_WEIGHT) {
              // Send transaction after signed
              _sendTransaction(state.transaction);
            } else {
              buildTxGeneralExceptionModal(
                  theme: theme,
                  context: context,
                  originRoute: widget.originRoute,
                  onAction: () => _sendTransaction(state.transaction));
            }
          } else if (state.transactionStatus == TransactionStatus.sending) {
            Navigator.popUntil(
                context, ModalRoute.withName(widget.originRoute));
            buildSendingTransactionModal(theme, context);
          } else if (state.transactionStatus == TransactionStatus.accepted) {
            buildSuccessfullTransaction(
                theme: theme,
                state: state,
                context: context,
                routeName: widget.originRoute,
                amountValue: getAmountValue(state),
                transactionType: widget.transactionType);
          }
        },
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            bool hasTimelock =
                state.transaction.hasTimelock(state.transactionType);
            String address = state.transaction.getOrigin(state.transactionType);
            return Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.txnDetails,
                        style: theme.textTheme.titleLarge,
                      ),
                      SizedBox(height: 24),
                      InfoElement(
                          label: isVttTransaction
                              ? localization.to
                              : localization.withdrawalAddress,
                          text: address),
                      InfoElement(
                        label: localization.amount,
                        text: getAmountValue(state),
                      ),
                      _timelock(state),
                      if (hasTimelock)
                        SizedBox(
                          height: 16,
                        ),
                      if (showFeeInfo) ..._buildTransactionFeeInfo(context),
                    ]));
          },
        ));
  }
}

List<Widget> _buildTransactionFeeInfo(BuildContext context) {
  int fee = BlocProvider.of<TransactionBloc>(context).getFee();
  return [
    InfoElement(
        label: localization.fee,
        isLastItem: true,
        text:
            '${fee.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
    SizedBox(height: 16),
  ];
}

Widget _timelock(TransactionState state) {
  if (state.transaction.hasTimelock(state.transactionType)) {
    int timestamp =
        state.transaction.vtTransaction?.body.outputs[0].timeLock.toInt() ??
            0 * 1000;
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
