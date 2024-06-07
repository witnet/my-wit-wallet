import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/speed_up_tx.dart';
import 'package:my_wit_wallet/widgets/transaction_details.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/widgets/transaction_item.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_modal.dart';
import 'package:witnet/schema.dart';

typedef void VoidCallback(GeneralTransaction? value);
typedef void ShowPaginationCallback(bool value);

class TransactionsList extends StatefulWidget {
  final ThemeData themeData;
  final VoidCallback setDetails;
  final GeneralTransaction? details;
  final Wallet currentWallet;
  final List<GeneralTransaction> transactions;
  final ShowPaginationCallback showPagination;
  TransactionsList(
      {Key? key,
      required this.themeData,
      required this.details,
      required this.setDetails,
      required this.transactions,
      required this.showPagination,
      required this.currentWallet})
      : super(key: key);

  @override
  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsList> {
  GeneralTransaction? transactionDetails;
  final ScrollController _scroller = ScrollController();
  GeneralTransaction? speedUpTransaction;
  Wallet currentWallet =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
  dynamic nextAction;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  void setTxSpeedUpStatus(GeneralTransaction? speedUpTx) {
    if (speedUpTx != null) {
      _prepareSpeedUpTx(speedUpTx);
    }
    setState(() {
      speedUpTransaction = speedUpTx;
    });
    if (speedUpTx != null) {
      widget.showPagination(false);
    } else {
      widget.showPagination(true);
    }
  }

  void _prepareSpeedUpTx(GeneralTransaction speedUpTx) {
    BlocProvider.of<TransactionBloc>(context).add(PrepareSpeedUpTxEvent(
        speedUpTx: speedUpTx,
        filteredUtxos: false,
        currentWallet: currentWallet,
        output: ValueTransferOutput.fromJson({
          'pkh': speedUpTx.vtt!.outputs.first.pkh.address,
          'value': speedUpTx.vtt!.outputs.first.value.toInt(),
          'time_lock': speedUpTx.vtt!.outputs.first.timeLock.toInt(),
        }),
        merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (speedUpTransaction != null) {
      return BlocListener<TransactionBloc, TransactionState>(
          listener: (BuildContext context, TransactionState state) {
            if (state.transactionStatus ==
                TransactionStatus.insufficientFunds) {
              ScaffoldMessenger.of(context).clearSnackBars();
              buildGeneralExceptionModal(
                  theme: theme,
                  context: context,
                  error: localization.insufficientFunds,
                  message: localization.insufficientUtxosAvailable,
                  originRouteName: DashboardScreen.route,
                  originRoute: DashboardScreen());
            }
          },
          child: SpeedUpVtt(
              speedUpTx: speedUpTransaction!,
              closeSetting: () => {
                    setTxSpeedUpStatus(null),
                  }));
    }

    if (widget.details != null) {
      return TransactionDetails(
        transaction: widget.details!,
        currentWallet: currentWallet,
        speedUpTx: setTxSpeedUpStatus,
        goToList: () => widget.setDetails(null),
      );
    }

    if (widget.transactions.length > 0) {
      return ListView.builder(
        controller: _scroller,
        padding: EdgeInsets.only(top: 8),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: widget.transactions.length,
        itemBuilder: (context, index) {
          GeneralTransaction transaction = widget.transactions[index];
          return TransactionsItem(
              transaction: transaction, showDetails: widget.setDetails);
        },
      );
    } else {
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                  ),
                  svgThemeImage(theme, name: 'no-transactions', height: 152),
                  SizedBox(
                    height: 24,
                  ),
                  Text(localization.txEmptyState)
                ]),
          )
        ],
      );
    }
  }
}
