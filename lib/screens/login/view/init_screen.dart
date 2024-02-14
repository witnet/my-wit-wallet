import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
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
        localization.welcome,
        style: theme.textTheme.displayLarge,
      ),
      Carousel(list: [
        localization.carouselMsg01,
        localization.carouselMsg02,
        localization.carouselMsg03,
      ])
    ];
  }

  Future<Widget> loadInitialScreen() async {
    ApiDatabase database = Locator.instance<ApiDatabase>();
    await database.loadOptimizeDbFile();
    WalletStorage storage = await database.loadWalletsDatabase();
    if (storage.wallets.isNotEmpty) {
      // There are wallets stored
      return LoginForm(mainComponents: mainComponents());
    } else {
      // No wallets stored yet
      return FtuActions(mainComponents: mainComponents());
    }
  }

  @override
  FutureBuilder<Widget> build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder(
      future: loadInitialScreen(),
      builder: (context, widget) {
        if (widget.connectionState == ConnectionState.done && widget.hasData) {
          return widget.data!;
        }
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
