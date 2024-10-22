import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/stats.dart';
import 'package:my_wit_wallet/screens/dashboard/view/transactions_view.dart';
import 'package:my_wit_wallet/widgets/step_bar.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';

enum DashboardViewSteps {
  transactions,
  stats,
}

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
  late Timer syncTimer;
  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  ScrollController scrollController = ScrollController(keepScrollOffset: true);
  ExplorerBloc? explorerBlock;
  String selectedItem =
      localizedDashboardSteps[DashboardViewSteps.transactions]!;

  @override
  void initState() {
    super.initState();
    _setWallet();
    _setAccount();
    String walletId = database.walletStorage.currentWallet.id;
    _syncWallet(walletId);
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    explorerBlock = BlocProvider.of<ExplorerBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    if (explorerBlock != null &&
        explorerBlock!.syncWalletSubscription != null) {
      explorerBlock!.syncWalletSubscription!.cancel();
    }
    super.dispose();
  }

  void _syncWallet(String walletId, {bool force = false}) {
    ExplorerBloc explorerBloc = BlocProvider.of<ExplorerBloc>(context);
    explorerBloc.add(SyncWalletEvent(
        explorerBloc.state.status, database.walletStorage.wallets[walletId]!,
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
  }

  BlocListener _dashboardListener() {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (BuildContext context, DashboardState state) {
        if (state.status == DashboardStatus.Ready) {
          _setNewWalletData();
          String walletId = database.walletStorage.currentWallet.id;
          _syncWallet(walletId, force: true);
        }
      },
      child: _dashboardBuilder(),
    );
  }

  void scrollToTop() {
    scrollController.jumpTo(0.0);
  }

  Widget buildTransactionsView() {
    return TransactionsView(
        currentWallet: currentWallet!, scrollJumpToTop: scrollToTop);
  }

  Widget buildMainDashboardContent(ThemeData theme) {
    if (localizedDashboardSteps[DashboardViewSteps.transactions]! ==
        selectedItem) {
      return buildTransactionsView();
    }
    return Stats(currentWallet: currentWallet!);
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    bool isHdWallet = currentWallet!.masterAccount == null;
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      return isHdWallet
          ? buildTransactionsView()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepBar(
                    selectedItem: selectedItem,
                    listItems: localizedDashboardSteps.values.toList(),
                    actionable: true,
                    onChanged: (item) => {
                          scrollController.jumpTo(0.0),
                          setState(
                            () => selectedItem = localizedDashboardSteps.entries
                                .firstWhere((element) => element.value == item)
                                .value,
                          ),
                        }),
                SizedBox(height: 24),
                buildMainDashboardContent(theme)
              ],
            );
    });
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
