import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/preferences/general_config.dart';
import 'package:my_wit_wallet/screens/preferences/wallet_config.dart';
import 'package:my_wit_wallet/widgets/layouts/dashboard_layout.dart';
import 'package:my_wit_wallet/widgets/step_bar.dart';

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
  ScrollController scrollController = ScrollController(keepScrollOffset: false);

  Widget _buildConfigView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepBar(
            actionable: true,
            selectedItem: stepSelectedItem,
            listItems: stepListItems,
            onChanged: (item) => {
                  scrollController.jumpTo(0.0),
                  setState(() => {stepSelectedItem = item!})
                }),
        SizedBox(height: 16),
        stepSelectedItem == ConfigSteps.General
            ? GeneralConfig()
            : WalletConfig(scrollController: scrollController)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      scrollController: scrollController,
      dashboardChild: _buildConfigView(),
      actions: [],
    );
  }
}
