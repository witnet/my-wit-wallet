import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
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
  general,
  wallet,
}

Map<String, ConfigSteps> _localizedConfigSteps(BuildContext context) {
  return {
    localization.preferenceTabs('general'): ConfigSteps.general,
    localization.preferenceTabs('wallet'): ConfigSteps.wallet,
  };
}

class _PreferencePageState extends State<PreferencePage> {
  ScrollController scrollController = ScrollController(keepScrollOffset: false);

  String? selectedItem;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildConfigView() {
    Widget view = GeneralConfig();
    if (selectedItem == null) {
      selectedItem = _localizedConfigSteps(context).keys.first;
      view = GeneralConfig();
    } else if (_localizedConfigSteps(context)[selectedItem]! ==
        ConfigSteps.general) {
      view = GeneralConfig();
    } else if (_localizedConfigSteps(context)[selectedItem]! ==
        ConfigSteps.wallet) {
      view = WalletConfig(scrollController: scrollController);
    } else {
      return GeneralConfig();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepBar(
            selectedItem:
                selectedItem ?? _localizedConfigSteps(context).keys.first,
            listItems: _localizedConfigSteps(context).keys.toList(),
            actionable: true,
            onChanged: (item) => {
                  scrollController.jumpTo(0.0),
                  setState(() => selectedItem = item),
                }),
        SizedBox(height: 16),
        view,
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
