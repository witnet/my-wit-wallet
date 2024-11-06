import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/preferences/general_config.dart';
import 'package:my_wit_wallet/screens/preferences/wallet_config.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
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

class _PreferencePageState extends State<PreferencePage> {
  ScrollController scrollController = ScrollController(keepScrollOffset: false);

  ConfigSteps currentStep = ConfigSteps.general;
  String selectedItem = localizedConfigSteps[ConfigSteps.general]!;
  WalletConfigActions? currentSetting = null;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleConfigNavigation(WalletConfigActions? value) {
    if (value != null) {
      setState(() {
        currentSetting = value;
      });
    } else {
      setState(() {
        currentSetting = null;
      });
    }
  }

  List<Widget> _buildConfigNavigation(BuildContext context) {
    final theme = Theme.of(context);
    return [
      Padding(
          padding: EdgeInsets.only(left: 8, right: 8),
          child:
              Text(localization.settings, style: theme.textTheme.titleLarge)),
      SizedBox(height: 16),
      StepBar(
          selectedItem: selectedItem,
          listItems: localizedConfigSteps.values.toList(),
          actionable: true,
          onChanged: (item) => {
                scrollController.jumpTo(0.0),
                setState(() {
                  selectedItem = localizedConfigSteps.entries
                      .firstWhere((element) => element.value == item)
                      .value;
                  currentStep = localizedConfigSteps.entries
                      .firstWhere((element) => element.value == item)
                      .key;
                }),
              })
    ];
  }

  Widget _buildConfigView() {
    Widget view = GeneralConfig();
    if (localizedConfigSteps[ConfigSteps.general] == selectedItem) {
      view = GeneralConfig();
    } else if (localizedConfigSteps[ConfigSteps.wallet] == selectedItem) {
      view = WalletConfig(
          savedSetting: currentSetting,
          scrollController: scrollController,
          toggleConfigNavigation: toggleConfigNavigation);
    } else {
      return GeneralConfig();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentSetting == null) ..._buildConfigNavigation(context),
        Padding(padding: EdgeInsets.only(left: 8, right: 8), child: view),
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
