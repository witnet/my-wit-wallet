import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/preferences/export_xprv.dart';
import 'package:my_wit_wallet/screens/preferences/sign_message.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/custom_divider.dart';

enum WalletConfigActions { exportXprv, signMsg }

class WalletConfig extends StatefulWidget {
  final ScrollController scrollController;

  WalletConfig({
    Key? key,
    required this.scrollController,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => WalletConfigState();
}

class WalletConfigState extends State<WalletConfig> {
  WalletConfigActions? currentSetting;

  @override
  void initState() {
    super.initState();
  }

  void _toggleSetting(WalletConfigActions action) {
    setState(() {
      currentSetting = action;
    });
  }

  void _clearCurrentSetting() {
    setState(() {
      currentSetting = null;
    });
  }

  Widget _buildWalletSetting() {
    switch (currentSetting) {
      case WalletConfigActions.exportXprv:
        return ExportXprv(
            scrollController: widget.scrollController,
            closeSetting: _clearCurrentSetting);
      case WalletConfigActions.signMsg:
        return SignMessage(
            scrollController: widget.scrollController,
            closeSetting: _clearCurrentSetting);
      case null:
        return Container();
    }
  }

  Widget _buildWalletSettingsSelection() {
    final theme = Theme.of(context);
    return Padding(
        padding: EdgeInsets.only(left: 8, right: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 32),
          Text(
            'Export the Xprv key of my wallet',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Text(
              'Your Xprv key allows you to export and back up your wallet at any point after creating it.',
              style: theme.textTheme.bodyLarge),
          PaddedButton(
              padding: EdgeInsets.only(bottom: 16, top: 16),
              text: 'Export xprv',
              type: ButtonType.primary,
              enabled: true,
              onPressed: () => _toggleSetting(WalletConfigActions.exportXprv)),
          CustomDivider(),
          Text(
            'Message Signing',
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Text(
              'Prove the ownership of your address by adding your signature to a message.',
              style: theme.textTheme.bodyLarge),
          PaddedButton(
              padding: EdgeInsets.only(bottom: 16, top: 16),
              text: 'Sign message',
              type: ButtonType.primary,
              enabled: true,
              onPressed: () => _toggleSetting(WalletConfigActions.signMsg)),
          SizedBox(height: 16),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return currentSetting == null
        ? _buildWalletSettingsSelection()
        : _buildWalletSetting();
  }
}
