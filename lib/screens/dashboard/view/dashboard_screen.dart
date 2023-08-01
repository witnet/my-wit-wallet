import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/widgets/transactions_list.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

class DashboardScreen extends StatefulWidget {
  static final route = '/dashboard';
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class PaginationParams {
  final int currentPage;
  final int limit;
  PaginationParams({this.currentPage = 1, this.limit = PAGINATION_LIMIT});
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String? currentAddress;
  Wallet? currentWallet;
  Account? currentAccount;
  GeneralTransaction? txDetails;
  late AnimationController _loadingController;
  late Timer syncTimer;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  List<GeneralTransaction> vtts = [];
  int numberOfPages = 0;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    String walletId = database.walletStorage.currentWallet.id;
    _setWallet();
    _setAccount();
    _syncWallet(walletId);
    getPaginatedTransactions(PaginationParams(currentPage: 1));
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _syncWallet(String walletId, {bool force = false}) {
    BlocProvider.of<ExplorerBloc>(context).add(SyncWalletEvent(
        ExplorerStatus.dataloading, database.walletStorage.wallets[walletId]!,
        force: force));
  }

  void _setWallet() {
    setState(() {
      currentWallet = database.walletStorage.currentWallet;
    });
  }

  void _setAccount() {
    setState(() {
      currentAccount = database.walletStorage.currentAccount;
    });
  }

  void _setNewWalletData() {
    _setWallet();
    _setAccount();
    getPaginatedTransactions(PaginationParams(currentPage: 1));
  }

  void _setDetails(GeneralTransaction? transaction) {
    scrollController.jumpTo(0.0);
    setState(() {
      txDetails = transaction;
    });
  }

  Widget _buildTransactionList(ThemeData themeData) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Column(children: [
      TransactionsList(
        themeData: themeData,
        setDetails: _setDetails,
        details: txDetails,
        valueTransfers: vtts,
        externalAddresses: currentWallet!.externalAccounts,
        internalAddresses: currentWallet!.internalAccounts,
        singleAddressAccount: currentWallet!.walletType == WalletType.single
            ? currentWallet!.masterAccount
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
                onPageChange: (int index) {
                  getPaginatedTransactions(
                      PaginationParams(currentPage: index + 1, limit: 10));
                },
              ))
          : SizedBox(height: 8),
      vtts.length > 0 ? SizedBox(height: 16) : SizedBox(height: 8),
    ]);
  }

  BlocListener _dashboardListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        if (state.status == DashboardStatus.Ready) {
          String walletId = database.walletStorage.currentWallet.id;
          _syncWallet(walletId, force: true);
        }
      },
      child: _dashboardBuilder(),
    );
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      return _buildTransactionList(theme);
    });
  }

  PaginatedData getPaginatedTransactions(PaginationParams args) {
    PaginatedData paginatedData = currentWallet!.getPaginatedTransactions(args);
    setState(() {
      numberOfPages = paginatedData.totalPages;
      vtts = paginatedData.data;
    });
    if (scrollController.hasClients) {
      scrollController.jumpTo(0.0);
    }
    return paginatedData;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplorerBloc, ExplorerState>(
        builder: (BuildContext context, ExplorerState state) {
      return DashboardLayout(
        scrollController: scrollController,
        dashboardChild: _dashboardListener(),
        actions: [],
      );
    }, listener: (context, state) {
      if (state.status == ExplorerStatus.dataloaded) {
        _setNewWalletData();
      }
    });
  }
}
