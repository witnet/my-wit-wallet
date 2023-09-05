import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/transactions_list.dart';
import 'package:number_paginator/number_paginator.dart';

typedef void VoidCallback();

class TransactionsView extends StatefulWidget {
  final Wallet currentWallet;
  final VoidCallback scrollJumpToTop;
  TransactionsView(
      {Key? key, required this.currentWallet, required this.scrollJumpToTop})
      : super(key: key);

  TransactionsListState createState() => TransactionsListState();
}

class TransactionsListState extends State<TransactionsView>
    with TickerProviderStateMixin {
  GeneralTransaction? txDetails;
  List<GeneralTransaction> vtts = [];
  int numberOfPages = 0;
  int currentPage = 0;
  @override
  void initState() {
    super.initState();
    getPaginatedTransactions(PaginationParams(currentPage: 1));
  }

  void _setDetails(GeneralTransaction? transaction) {
    widget.scrollJumpToTop();
    setState(() {
      txDetails = transaction;
    });
  }

  PaginatedData getPaginatedTransactions(PaginationParams args) {
    PaginatedData paginatedData =
        widget.currentWallet.getPaginatedTransactions(args);
    setState(() {
      numberOfPages = paginatedData.totalPages;
      vtts = paginatedData.data;
    });
    return paginatedData;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final extendedTheme = themeData.extension<ExtendedTheme>()!;
    return Column(children: [
      TransactionsList(
        themeData: themeData,
        setDetails: _setDetails,
        details: txDetails,
        valueTransfers: vtts,
        externalAddresses: widget.currentWallet.externalAccounts,
        internalAddresses: widget.currentWallet.internalAccounts,
        singleAddressAccount:
            widget.currentWallet.walletType == WalletType.single
                ? widget.currentWallet.masterAccount
                : null,
      ),
      (numberOfPages > 1 && txDetails == null)
          ? Container(
              width: numberOfPages < 4 ? 250 : null,
              alignment: Alignment.center,
              child: NumberPaginator(
                config: NumberPaginatorUIConfig(
                  mainAxisAlignment: MainAxisAlignment.center,
                  buttonSelectedBackgroundColor:
                      extendedTheme.numberPaginatiorSelectedBg,
                  buttonUnselectedForegroundColor:
                      extendedTheme.numberPaginatiorUnselectedFg,
                ),
                numberPages: numberOfPages,
                initialPage: currentPage,
                onPageChange: (int index) {
                  widget.scrollJumpToTop();
                  setState(() {
                    currentPage = index;
                  });
                  getPaginatedTransactions(
                      PaginationParams(currentPage: index + 1, limit: 10));
                },
              ))
          : SizedBox(height: 8),
      vtts.length > 0 ? SizedBox(height: 16) : SizedBox(height: 8),
    ]);
  }
}
