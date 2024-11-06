import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/preferences/delete_wallet.dart';
import 'package:my_wit_wallet/screens/preferences/export_xprv.dart';
import 'package:my_wit_wallet/screens/preferences/sign_message.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/custom_divider.dart';

enum WalletConfigActions { exportXprv, signMsg, deleteWallet }

typedef void WalletConfigActionsCallback(WalletConfigActions? value);

class WalletConfig extends StatefulWidget {
  final ScrollController scrollController;
  final WalletConfigActionsCallback toggleConfigNavigation;
  final WalletConfigActions? savedSetting;

  WalletConfig(
      {Key? key,
      required this.scrollController,
      required this.savedSetting,
      required this.toggleConfigNavigation})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => WalletConfigState();
}

class WalletConfigState extends State<WalletConfig> {
  WalletConfigActions? currentSetting;

  @override
  void initState() {
    super.initState();
    currentSetting = widget.savedSetting;
  }

  void _toggleSetting(WalletConfigActions? action) {
    widget.toggleConfigNavigation(action);
    setState(() {
      currentSetting = action;
    });
  }

  void _clearCurrentSetting() {
    widget.scrollController.jumpTo(0.0);
    _toggleSetting(null);
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
      case WalletConfigActions.deleteWallet:
        return DeleteSingleWallet(
            scrollController: widget.scrollController,
            closeSetting: _clearCurrentSetting);
      case null:
        return Container();
    }
  }

  Widget _buildWalletSettingsSelection() {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 24),
      Text(
        localization.walletConfigHeader,
        style: theme.textTheme.titleMedium,
      ),
      SizedBox(height: 8),
      Text(localization.walletConfig01, style: theme.textTheme.bodyMedium),
      PaddedButton(
          padding: EdgeInsets.only(bottom: 16, top: 16),
          text: localization.exportXprv,
          type: ButtonType.primary,
          enabled: true,
          onPressed: () => _toggleSetting(WalletConfigActions.exportXprv)),
      CustomDivider(),
      Text(
        localization.messageSigning,
        style: theme.textTheme.titleMedium,
      ),
      SizedBox(height: 8),
      Text(localization.messageSigning01, style: theme.textTheme.bodyMedium),
      PaddedButton(
          padding: EdgeInsets.only(bottom: 16, top: 16),
          text: localization.signMessage,
          type: ButtonType.primary,
          enabled: true,
          onPressed: () => _toggleSetting(WalletConfigActions.signMsg)),
      SizedBox(height: 16),
      CustomDivider(),
      Text(
        localization.deleteWallet,
        style: theme.textTheme.titleMedium,
      ),
      SizedBox(height: 16),
      Text(localization.deleteWallet01, style: theme.textTheme.bodyMedium),
      PaddedButton(
          padding: EdgeInsets.only(bottom: 16, top: 16),
          text: localization.deleteWallet,
          type: ButtonType.primary,
          enabled: true,
          onPressed: () => _toggleSetting(WalletConfigActions.deleteWallet)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return currentSetting == null
        ? _buildWalletSettingsSelection()
        : _buildWalletSetting();
  }
}
