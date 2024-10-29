import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/speed_up_tx.dart';
import 'package:my_wit_wallet/widgets/transaction_details.dart';
import 'package:my_wit_wallet/widgets/transactions_list.dart';
import 'package:my_wit_wallet/widgets/witnet/transactions/value_transfer/modals/general_error_modal.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:witnet/schema.dart';

typedef void BoolCallback(bool value);
typedef void VoidCallback();

class TransactionsView extends StatefulWidget {
  final BoolCallback toggleDashboardInfo;
  final VoidCallback scrollJumpToTop;

  TransactionsView(
      {Key? key,
      required this.toggleDashboardInfo,
      required this.scrollJumpToTop})
      : super(key: key);

  TransactionsViewState createState() => TransactionsViewState();
}

class TransactionsViewState extends State<TransactionsView>
    with TickerProviderStateMixin {
  GeneralTransaction? txDetails;
  GeneralTransaction? speedUpTransaction;
  List<GeneralTransaction> transactions = [];
  int numberOfPages = 0;
  int currentPage = 0;
  bool showPagination = true;
  Wallet get currentWallet =>
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;

  @override
  void initState() {
    super.initState();
    getPaginatedTransactions(PaginationParams(currentPage: 1));
  }

  void _setDetails(GeneralTransaction? transaction) {
    setState(() {
      txDetails = transaction;
    });
    if (txDetails != null) {
      widget.scrollJumpToTop();
      widget.toggleDashboardInfo(false);
    } else {
      widget.toggleDashboardInfo(true);
    }
  }

  PaginatedData getPaginatedTransactions(PaginationParams args) {
    PaginatedData paginatedData = currentWallet.getPaginatedTransactions(args);
    setState(() {
      numberOfPages = paginatedData.totalPages;
      transactions = paginatedData.data;
    });
    return paginatedData;
  }

  Widget buildPagination(ExtendedTheme theme) {
    if (numberOfPages > 1 && txDetails == null && showPagination) {
      return Container(
          width: numberOfPages < 4 ? 250 : null,
          alignment: Alignment.center,
          child: NumberPaginator(
            config: NumberPaginatorUIConfig(
              mainAxisAlignment: MainAxisAlignment.center,
              buttonSelectedBackgroundColor: theme.numberPaginatiorSelectedBg,
              buttonUnselectedForegroundColor:
                  theme.numberPaginatiorUnselectedFg,
            ),
            numberPages: numberOfPages,
            initialPage: currentPage,
            onPageChange: (int index) {
              setState(() {
                currentPage = index;
              });
              getPaginatedTransactions(
                  PaginationParams(currentPage: index + 1, limit: 10));
            },
          ));
    } else {
      return SizedBox(height: 8);
    }
  }

  void setTxSpeedUpStatus(GeneralTransaction? speedUpTx) {
    if (speedUpTx != null) {
      _prepareSpeedUpTx(speedUpTx);
    }
    setState(() {
      speedUpTransaction = speedUpTx;
    });
    if (speedUpTx != null) {
      widget.scrollJumpToTop();
      widget.toggleDashboardInfo(false);
      setState(() {
        showPagination = false;
      });
    } else {
      widget.toggleDashboardInfo(true);
      setState(() {
        showPagination = true;
      });
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
    final themeData = Theme.of(context);
    final extendedTheme = themeData.extension<ExtendedTheme>()!;
    if (speedUpTransaction != null) {
      return BlocListener<TransactionBloc, TransactionState>(
          listener: (BuildContext context, TransactionState state) {
            if (state.transactionStatus ==
                TransactionStatus.insufficientFunds) {
              ScaffoldMessenger.of(context).clearSnackBars();
              buildGeneralExceptionModal(
                  theme: themeData,
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

    if (txDetails != null) {
      return TransactionDetails(
        transaction: txDetails!,
        currentWallet: currentWallet,
        speedUpTx: setTxSpeedUpStatus,
        goToList: () => _setDetails(null),
      );
    }

    return BlocListener<ExplorerBloc, ExplorerState>(
      listener: (context, state) {
        if (state.status == ExplorerStatus.dataloaded) {
          getPaginatedTransactions(
              PaginationParams(currentPage: currentPage + 1, limit: 10));
        }
      },
      child: Column(children: [
        TransactionsList(
          themeData: themeData,
          showPagination: (bool value) => {
            if (this.mounted)
              {
                setState(() {
                  showPagination = value;
                })
              }
          },
          setDetails: _setDetails,
          details: txDetails,
          transactions: transactions,
          currentWallet: currentWallet,
        ),
        buildPagination(extendedTheme),
      ]),
    );
  }
}
