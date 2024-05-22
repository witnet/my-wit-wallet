import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
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

  TransactionsViewState createState() => TransactionsViewState();
}

class TransactionsViewState extends State<TransactionsView>
    with TickerProviderStateMixin {
  GeneralTransaction? txDetails;
  List<GeneralTransaction> transactions = [];
  int numberOfPages = 0;
  int currentPage = 0;
  bool showPagination = true;
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
              widget.scrollJumpToTop();
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

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final extendedTheme = themeData.extension<ExtendedTheme>()!;
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
          currentWallet: widget.currentWallet,
        ),
        buildPagination(extendedTheme),
      ]),
    );
  }
}
