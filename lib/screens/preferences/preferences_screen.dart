import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/theme/theme_bloc.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';

class PreferencePage extends StatelessWidget {
  const PreferencePage({Key? key}) : super(key: key);

  Widget themeWidget(double height) {
    return Container(
      height: height,
      child: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: WalletTheme.values.length,
        itemBuilder: (context, index) {
          // Store the theme for the current ListView item
          final itemAppTheme = WalletTheme.values[index];
          return Card(
            // Style the cards with the to-be-selected theme colors
            color: walletThemeData[itemAppTheme]!.cardTheme.color,
            child: ListTile(
              title: Text(
                itemAppTheme.toString(),
                // To show light text with the dark variants...
                style: walletThemeData[itemAppTheme]!.textTheme.button,
              ),
              onTap: () {
                // This will make the Bloc output a new ThemeState,
                // which will rebuild the UI because of the BlocBuilder in main.dart
                BlocProvider.of<ThemeBloc>(context)
                    .add(ThemeChanged(itemAppTheme));
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Preferences'),
      ),
      body: Container(
        child: Column(
          children: [
            themeWidget(deviceSize.height * 0.25),
          ],
        ),
      ),
    );
  }
}
