import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/util/preferences.dart';
import 'package:witnet_wallet/widgets/transactions_list.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';

import '../api_dashboard.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardScreen extends StatefulWidget {
  static final route = '/dashboard';
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  String? walletId;
  String? currentAddress;
  Wallet? currentWallet;
  Account? currentAccount;
  ValueTransferInfo? txDetails;
  late AnimationController _loadingController;

  ApiDatabase database = Locator.instance.get<ApiDatabase>();
  ApiDashboard api = Locator.instance.get<ApiDashboard>();

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    _getVtts();
    //BlocProvider.of<DashboardBloc>(context).add(DashboardUpdateWalletEvent(currentWallet: currentWallet, currentAddress: currentAccount!.address));
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _syncWallet(String walletId) {
    BlocProvider.of<ExplorerBloc>(context)
    .add(SyncWalletEvent(ExplorerStatus.dataloading, database.walletStorage.wallets[walletId]!));
  }

   void _getVtts() {

    _setWallet();
    _setAccount();

    print(currentWallet!.allTransactions());
    print(currentWallet!.txHashes);
    print(currentAccount!.address);
  }

  void _setWallet() {
    setState(() {
      currentWallet = Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
    });
  }

  void _setAccount() {
    setState(() {
      currentAccount = Locator.instance.get<ApiDatabase>().walletStorage.currentAccount;
    });
  }

  void _setDetails(ValueTransferInfo? transaction) {
    setState(() {
      txDetails = transaction;
    });
  }

  Widget _buildTransactionList(ThemeData themeData){
    return TransactionsList(
      themeData: themeData,
      setDetails: _setDetails,
      details: txDetails,
      valueTransfers: currentWallet!.allTransactions(),
      externalAddresses: currentWallet!.externalAccounts,
      txHashes: currentWallet!.txHashes,
    );
  }


  BlocListener _explorerListener(){
    return BlocListener<ExplorerBloc, ExplorerState>(
      listener: (BuildContext context, ExplorerState state){

      }
    );
  }

  BlocListener _dashboardListener(){
    return BlocListener<DashboardBloc, DashboardState>(
        listener: (BuildContext context, DashboardState state) {
          print(state.props);
          if(state.status == DashboardStatus.Ready){
            setState(() {

            currentWallet = database.walletStorage.wallets[state.currentWalletId];
            currentAccount = currentWallet!.accountByAddress(state.currentAddress);
            api.setCurrentAccount(currentAccount!);
            api.setCurrentWalletData(currentWallet);
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExplorerBloc, ExplorerState>(
        builder: (BuildContext context, ExplorerState state) {
      return DashboardLayout(
        dashboardChild: _dashboardListener(),
        actions: [],
      );
    }, listener: (context, state) {

    });
  }
}
