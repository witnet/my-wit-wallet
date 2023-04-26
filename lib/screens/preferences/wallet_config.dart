import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/dashed_rect.dart';
import 'package:my_wit_wallet/widgets/generate_compatible_xprv.dart';
import 'package:my_wit_wallet/widgets/verify_password.dart';

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
  String? newXprv;
  bool showXprv = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _exportWalletContent(BuildContext context) {
    Widget verifyPassword = VerifyPassword(
        onXprvGenerated: (generatedXprv) =>
            {setState(() => xprv = generatedXprv)});
    Widget encryptXprv = GenerateCompatibleXprv(
        xprv: xprv,
        onXprvGenerated: (generatedXprv) =>
            {setState(() => newXprv = generatedXprv)});
    Widget xprvOutput = Column(children: [
      DashedRect(
          color: Colors.grey,
          strokeWidth: 1.0,
          gap: 3.0,
          showEye: true,
          blur: !showXprv,
          text: newXprv ?? '',
          updateBlur: () => {
                setState(() {
                  showXprv = !showXprv;
                })
              }),
      SizedBox(height: 16),
      PaddedButton(
        text: 'Copy Xprv',
        type: 'primary',
        padding: EdgeInsets.only(bottom: 8),
        onPressed: () =>
            {Clipboard.setData(ClipboardData(text: newXprv ?? ''))},
      ),
    ]);
    if (newXprv != null) {
      return xprvOutput;
    } else if (xprv == null) {
      return verifyPassword;
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
          'Export the Xprv key of my wallet',
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Text(
            'Your Xprv key allows you to export and back up your wallet at any point after creating it.',
            style: theme.textTheme.bodyLarge),
        SizedBox(height: 8),
        Text(
            'Privacy-wise, your Xprv key is equivalent to a secret recovery phrase. Do not share it with anyone, and never store it in a file in your device or anywhere else electronically.',
            style: theme.textTheme.bodyLarge),
        SizedBox(height: 8),
        Text(
            'Your Xprv key will be protected with the password below. When importing the Xprv on this or other app, you will be asked to type in that same password.',
            style: theme.textTheme.bodyLarge),
        SizedBox(height: 16),
        _exportWalletContent(context),
      ]);
    });
  }
}
