import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/preferences/export_xprv.dart';
import 'package:my_wit_wallet/screens/preferences/sign_message.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  AppLocalizations get _localization => AppLocalizations.of(context)!;

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
            _localization.walletConfigHeader,
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Text(_localization.walletConfig01, style: theme.textTheme.bodyLarge),
          PaddedButton(
              padding: EdgeInsets.only(bottom: 16, top: 16),
              text: _localization.exportXprv,
              type: ButtonType.primary,
              enabled: true,
              onPressed: () => _toggleSetting(WalletConfigActions.exportXprv)),
          CustomDivider(),
          Text(
            _localization.messageSigning,
            style: theme.textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Text(_localization.messageSigning01,
              style: theme.textTheme.bodyLarge),
          PaddedButton(
              padding: EdgeInsets.only(bottom: 16, top: 16),
              text: _localization.signMessage,
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
