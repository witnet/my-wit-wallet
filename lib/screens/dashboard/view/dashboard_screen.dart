import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:witnet/explorer.dart';
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
  String? walletId;
  String? currentAddress;
  Wallet? currentWallet;
  Account? currentAccount;
  ValueTransferInfo? txDetails;
  late AnimationController _loadingController;
  late Timer syncTimer;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  List<ValueTransferInfo> vtts = [];
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
    syncTimer = Timer.periodic(Duration(minutes: 0, seconds: 30), (timer) {
      _syncWallet(walletId);
    });
    getPaginatedTransactions(PaginationParams(currentPage: 1));
    //BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(currentWallet: currentWallet, currentAddress: currentAccount!.address));
  }

  @override
  void deactivate() {
    syncTimer.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    syncTimer.cancel();
    super.dispose();
  }

  void _syncWallet(String walletId) {
    BlocProvider.of<ExplorerBloc>(context).add(SyncWalletEvent(
        ExplorerStatus.dataloading, database.walletStorage.wallets[walletId]!));
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

  void _setDetails(ValueTransferInfo? transaction) {
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
      (vtts.length > 0 && txDetails == null)
          ? NumberPaginator(
              config: NumberPaginatorUIConfig(
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
            )
          : SizedBox(height: 8),
      vtts.length > 0 ? SizedBox(height: 16) : SizedBox(height: 8),
    ]);
  }

  BlocListener _dashboardListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        if (state.status == DashboardStatus.Ready) {
          _setNewWalletData();
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
