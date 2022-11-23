import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/vtt_create/vtt_create_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:witnet_wallet/widgets/auto_size_text.dart';
import 'package:witnet_wallet/widgets/round_button.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:witnet_wallet/widgets/witnet/wallet/receive_dialog.dart';

class ReceiveTransactionScreen extends StatefulWidget {
  static final route = '/receive-transaction';
  @override
  ReceiveTransactionScreenState createState() =>
      ReceiveTransactionScreenState();
}

class ReceiveTransactionScreenState extends State<ReceiveTransactionScreen>
    with TickerProviderStateMixin {
  Wallet? walletStorage;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingController.forward();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Widget _buildReceiveTransactionScreen() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (previous, current) {
        if (current.status != DashboardStatus.Ready) {
          Navigator.pushReplacementNamed(context, LoginScreen.route);
          return false;
        } else if (current.currentWallet.id != previous.currentWallet.id) {
          Navigator.pushReplacementNamed(context, DashboardScreen.route);
          return false;
        }
        return true;
      },
      builder: (context, state) {
        return ReceiveDialogBox(walletStorage: state.currentWallet);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DashboardLayout(
        dashboardChild: _buildReceiveTransactionScreen(),
        actions: [],
      ),
    );
  }
}
