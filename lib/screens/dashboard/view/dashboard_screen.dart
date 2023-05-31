import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/widgets/pagination.dart';
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
  PaginationParams({this.currentPage = 1, this.limit = 10});
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

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    _setWallet();
    _setAccount();
    _syncWallet(database.walletStorage.currentWallet.id);
    syncTimer = Timer.periodic(Duration(minutes: 0, seconds: 30), (timer) {
      _syncWallet(database.walletStorage.currentWallet.id);
    });
    //BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(currentWallet: currentWallet, currentAddress: currentAccount!.address));
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
      currentWallet =
          Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
    });
  }

  void _setAccount() {
    setState(() {
      currentAccount =
          Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
    });
  }

  void _setDetails(ValueTransferInfo? transaction) {
    scrollController.jumpTo(0.0);
    setState(() {
      txDetails = transaction;
    });
  }

  Widget _buildTransactionList(ThemeData themeData) {
    return TransactionsList(
      themeData: themeData,
      setDetails: _setDetails,
      details: txDetails,
      valueTransfers: vtts,
      externalAddresses: currentWallet!.externalAccounts,
      internalAddresses: currentWallet!.internalAccounts,
    );
  }

  BlocListener _dashboardListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        if (state.status == DashboardStatus.Ready) {
          setState(() {
            _setWallet();
            _setAccount();
          });
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
      vtts = paginatedData.data as List<ValueTransferInfo>;
    });
    return paginatedData;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplorerBloc, ExplorerState>(
        builder: (BuildContext context, ExplorerState state) {
      return DashboardLayout(
        scrollController: scrollController,
        getPaginatedData: getPaginatedTransactions,
        dashboardChild: _dashboardListener(),
        actions: [],
      );
    }, listener: (context, state) {
      if (state.status == ExplorerStatus.dataloaded) {
        setState(() {
          _setWallet();
          _setAccount();
        });
      }
    });
  }
}
