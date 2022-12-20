import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text(
        'Export xprv',
        style: theme.textTheme.headline5,
      )
    ]);
  }
}
