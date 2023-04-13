import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/dashed_rect.dart';
import 'package:witnet_wallet/widgets/generate_compatible_xprv.dart';

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
  String? xprv;
  bool showXprv = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _exportWalletContent(BuildContext context) {
    Widget encryptXprv = GenerateCompatibleXprv(onXprvGenerated: (generatedXprv) => {
      setState(() => xprv = generatedXprv)
    });
    Widget xprvOutput = Column(children: [
      DashedRect(
          color: Colors.grey,
          strokeWidth: 1.0,
          gap: 3.0,
          showEye: true,
          blur: !showXprv,
          text: xprv ?? '',
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
          Clipboard.setData(ClipboardData(
              text: xprv ?? ''))
        },
      ),
    ]);
    if (xprv != null) {
      return xprvOutput;
    } else {
      return encryptXprv;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<DashboardBloc, DashboardState>(
        builder: (previous, current) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Export wallet from xprv',
          style: theme.textTheme.titleSmall,
        ),
        SizedBox(height: 16),
        _exportWalletContent(context),
      ]);
    });
  }
}
