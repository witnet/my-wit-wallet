import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/preferences/general_config.dart';
import 'package:witnet_wallet/screens/preferences/wallet_config.dart';
import 'package:witnet_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:witnet_wallet/widgets/step_bar.dart';

class PreferencePage extends StatefulWidget {
  PreferencePage({Key? key}) : super(key: key);
  static final route = '/configuration';
  @override
  State<StatefulWidget> createState() => _PreferencePageState();
}

enum ConfigSteps {
  General,
  Wallet,
}

class _PreferencePageState extends State<PreferencePage> {
  bool checked = false;
  List<ConfigSteps> stepListItems = ConfigSteps.values.toList();
  Enum stepSelectedItem = ConfigSteps.General;

  Widget _buildConfigView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepBar(
            actionable: true,
            selectedItem: stepSelectedItem,
            listItems: stepListItems,
            onChanged: (item) => {
                  setState(() => {stepSelectedItem = item!})
                }),
        SizedBox(height: 16),
        stepSelectedItem == ConfigSteps.General
            ? GeneralConfig()
            : WalletConfig()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      dashboardChild: _buildConfigView(),
      actions: [],
    );
  }
}
