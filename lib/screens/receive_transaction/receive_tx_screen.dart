import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:witnet_wallet/screens/login/view/login_screen.dart';
import 'package:witnet_wallet/theme/colors.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/dashed_rect.dart';
import 'package:witnet_wallet/widgets/qr/qr_address_generator.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';

class ReceiveTransactionScreen extends StatefulWidget {
  static final route = '/receive-transaction';
  @override
  ReceiveTransactionScreenState createState() =>
      ReceiveTransactionScreenState();
}

class ReceiveTransactionScreenState extends State<ReceiveTransactionScreen>
    with TickerProviderStateMixin {
  String currentAddress = '';
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

  List<Widget> _actions() {
    return [
      PaddedButton(
          padding: EdgeInsets.only(bottom: 8),
          text: 'Copy',
          type: 'primary',
          enabled: true,
          onPressed: () =>
              {Clipboard.setData(ClipboardData(text: currentAddress))}),
      // TODO: add button to generate new address
      // PaddedButton(
      //     padding: EdgeInsets.only(bottom: 8),
      //     text: 'Generate new',
      //     type: 'secondary',
      //     enabled: true,
      //     onPressed: () => {
      //           // generate new address change address index
      //         }),
    ];
  }

  _setCurrentWallet(Wallet? currentWallet) {
    setState(() {
      currentAddress =
          currentWallet?.externalAccounts[0]?.address.toString() ?? '';
    });
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
        _setCurrentWallet(current.currentWallet);
        return true;
      },
      builder: (context, state) {
        return Column(
          children: [
            QrAddressGenerator(
              data: currentAddress,
            ),
            SizedBox(height: 24),
            DashedRect(
              color: WitnetPallet.witnetGreen2,
              strokeWidth: 1.0,
              gap: 3.0,
              text: currentAddress,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DashboardLayout(
        dashboardChild: _buildReceiveTransactionScreen(),
        actions: _actions(),
      ),
    );
  }
}
