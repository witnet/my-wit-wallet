import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/stats.dart';
import 'package:my_wit_wallet/screens/dashboard/view/transactions_view.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/panel.dart';
import 'package:my_wit_wallet/widgets/balance_details.dart';
import 'package:my_wit_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/tap_bar.dart';
import 'package:my_wit_wallet/widgets/wallet_info.dart';

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
  final PanelUtils panel = Locator.instance.get<PanelUtils>();
  Widget get panelContent => panel.getContent();
  bool dashboardNavigation = true;

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

  void toogleDashboardNavigation(bool show) {
    if (show) {
      setState(() {
        dashboardNavigation = true;
      });
    } else {
      setState(() {
        dashboardNavigation = false;
      });
    }
  }

  Widget buildMainDashboardContent(ThemeData theme) {
    if (localizedDashboardSteps[DashboardViewSteps.transactions]! ==
        selectedItem) {
      return TransactionsView(
          toggleDashboardInfo: toogleDashboardNavigation,
          scrollJumpToTop: scrollToTop);
    }
    return Stats(currentWallet: currentWallet!);
  }

  List<Widget> dashboardInfo() {
    return [
      Padding(
        padding: EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 0),
        child: svgThemeImage(Theme.of(context),
            name: 'myWitWallet-title', width: 124),
      ),
      SizedBox(height: 16),
      WalletInfo(
          currentWallet: currentWallet!,
          onShowBalanceDetails: () async => {
                setState(() => panel.setContent(BalanceDetails(
                    balance: currentWallet!.balanceNanoWit(),
                    stakedBalance: currentWallet!.stakedNanoWit()))),
                await panel.toggle(),
              }),
      SizedBox(height: 8)
    ];
  }

  List<Widget> dashboardInfoNavigation() {
    return [
      ...dashboardInfo(),
      SizedBox(height: 8),
      TapBar(
          selectedItem: selectedItem,
          listItems: localizedDashboardSteps.values.toList(),
          actionable: true,
          onChanged: (item) => {
                scrollToTop(),
                setState(
                  () => selectedItem = localizedDashboardSteps.entries
                      .firstWhere((element) => element.value == item)
                      .value,
                ),
              }),
    ];
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    bool isHdWallet = currentWallet!.masterAccount == null;
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      return isHdWallet
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dashboardNavigation) ...dashboardInfo(),
                buildMainDashboardContent(theme)
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dashboardNavigation) ...dashboardInfoNavigation(),
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
