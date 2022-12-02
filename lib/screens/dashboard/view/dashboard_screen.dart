import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/bloc/explorer/explorer_bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/widgets/transactions_list.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';

const headerAniInterval = Interval(.1, .3, curve: Curves.easeOut);

class DashboardScreen extends StatefulWidget {
  static final route = '/dashboard';
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, Account> externalAccounts = {};
  Map<String, Account> internalAccounts = {};
  List<ValueTransferInfo> valueTransfers = [];
  Wallet? walletStorage;
  ValueTransferInfo? txDetails;
  late AnimationController _loadingController;
  List<String>? walletList;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
    _getVtts();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  void _syncWallet(Wallet wallet) {
    wallet.externalAccounts.forEach((key, value) {
      BlocProvider.of<CryptoBloc>(context).syncAccountValueTransfers(value);
    });
    BlocProvider.of<ExplorerBloc>(context)
        .add(SyncWalletEvent(ExplorerStatus.dataloading, wallet));
  }

  void _getVtts() async {
    valueTransfers = await Locator.instance<ApiDatabase>().getAllVtts();
  }

  _setDetails(ValueTransferInfo? transaction) {
    setState(() {
      txDetails = transaction;
    });
  }

  Widget _buildTransactionsList(ThemeData themeData, DashboardState state) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) {
        if (previous.currentWallet.id != current.currentWallet.id) {
          setState(() {
            walletStorage = current.currentWallet;
            _syncWallet(current.currentWallet);
            txDetails = null;
          });
        }
        return true;
      },
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TransactionsList(
              themeData: themeData,
              setDetails: _setDetails,
              details: txDetails,
              valueTransfers: valueTransfers,
              externalAddresses: state.currentWallet.externalAccounts,
              txHashes: state.currentWallet.txHashes,
            )
          ],
        );
      },
    );
  }

  Widget _dashboardBuilder() {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (BuildContext context, DashboardState state) {
      if (state.status == DashboardStatus.Loading) {
        return _buildTransactionsList(theme, state);
      } else if (state.status == DashboardStatus.Synchronized) {
        walletStorage = state.currentWallet;
        return _buildTransactionsList(theme, state);
      } else if (state.status == DashboardStatus.Synchronizing) {
        return SpinKitWave(
          color: theme.primaryColor,
        );
      } else if (state.status == DashboardStatus.Ready) {
        walletStorage = state.currentWallet;
        return _buildTransactionsList(theme, state);
      } else {
        return SpinKitWave(
          color: theme.primaryColor,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DashboardLayout(
        dashboardChild: _dashboardBuilder(),
        actions: [],
      ),
    );
  }
}
