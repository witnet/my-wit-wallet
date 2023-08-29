import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/login/view/ftu_actions.dart';
import 'package:my_wit_wallet/screens/login/view/login_form.dart';
import 'package:my_wit_wallet/theme/wallet_theme.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';
import 'package:my_wit_wallet/widgets/carousel.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/shared/api_database.dart';

class InitScreen extends StatefulWidget {
  static final route = '/';

  InitScreen({Key? key}) : super(key: key);

  @override
  InitScreenState createState() => InitScreenState();
}

class InitScreenState extends State<InitScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<Widget> mainComponents() {
    final theme = Theme.of(context);
    return [
      Padding(
        padding: EdgeInsets.only(left: 24, right: 24),
        child: witnetLogo(Theme.of(context)),
      ),
      Text(
        'Welcome',
        style: theme.textTheme.displayLarge,
      ),
      Carousel(list: [
        'myWitWallet allows you to send and receive Wit immediately. Bye bye synchronization!',
        'myWitWallet uses state-of-the-art cryptography to store your Wit coins securely.',
        'myWitWallet is completely non-custodial. Your keys will never leave your device.',
      ])
    ];
  }

  Future<WalletStorage> loadWalletsDatabase() async {
    return await Locator.instance<ApiDatabase>().loadWalletsDatabase();
  }

  @override
  FutureBuilder<WalletStorage> build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: loadWalletsDatabase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            if (snapshot.data!.wallets.isNotEmpty) {
              // There are wallets stored
              return LoginForm(mainComponents: mainComponents());
            } else {
              // No wallets stored yet
              return FtuActions(mainComponents: mainComponents());
            }
          }
        }
        // Default screen while loading wallets
        return Layout(
          navigationActions: [],
          widgetList: [
            ...mainComponents(),
            SizedBox(height: 32),
            SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(
                  color: theme.textTheme.labelMedium?.color,
                  strokeWidth: 2,
                  value: null,
                  semanticsLabel: 'Circular progress indicator',
                ))
          ],
          actions: [],
        );
      },
    );
  }
}
