import 'package:flutter/material.dart';
import 'package:witnet_wallet/widgets/switch.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/layout.dart';

class PreferencePage extends StatefulWidget {
  PreferencePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  bool checked = false;

  Widget themeWidget(heigh, context) {
    return Row(children: [
      CustomSwitch(
          checked: checked,
          primaryLabel: 'Dark Mode',
          secondaryLabel: 'Light Mode',
          onChanged: (value) => {
                setState(() {
                  checked = !checked;
                  BlocProvider.of<ThemeBloc>(context).add(ThemeChanged(
                      checked ? WalletTheme.Dark : WalletTheme.Light));
                })
              }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Layout(
      widgetList: [
        themeWidget(deviceSize.height * 0.25, context),
      ],
      appBar: AppBar(
        title: Text('Preferences'),
      ),
    );
  }
}
