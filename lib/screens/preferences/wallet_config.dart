import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/dashed_rect.dart';

class WalletConfig extends StatefulWidget {
  WalletConfig({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _WalletConfigState();
}

enum ConfigSteps {
  General,
  Wallet,
}

class _WalletConfigState extends State<WalletConfig> {
  String xprv = '';
  bool showXprv = false;
  final apiDashboard = Locator.instance<ApiDashboard>().walletStorage!;

  @override
  void initState() {
    super.initState();
    print(apiDashboard);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (previous, current) {

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Export wallet from xprv',
          style: theme.textTheme.subtitle2,
        ),
        SizedBox(height: 16),
        DashedRect(
            color: Colors.grey,
            strokeWidth: 1.0,
            gap: 3.0,
            showEye: true,
            blur: !showXprv,
            text: Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv ?? '',
            updateBlur: () => {
                  setState(() {
                    showXprv = !showXprv;
                  })
                }),
        SizedBox(height: 16),
        PaddedButton(
          text: 'Copy XPRV',
          type: 'primary',
          padding: EdgeInsets.only(bottom: 8),
          onPressed: () => {
            Clipboard.setData(
                ClipboardData(text: Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv ?? ''))
          },
        ),
      ]);
    });
  }
}
