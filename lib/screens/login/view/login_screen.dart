import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/login/view/login_form.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/layout.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';

class LoginScreen extends StatefulWidget {
  static final route = '/login';

  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Layout(
      widgetList: [
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          witnetLogo(theme),
          PaddedButton(
            padding: EdgeInsets.only(top: 8, bottom: 8),
            text: 'Create new wallet',
            onPressed: () => {}),
          LoginForm(),
        ],
      ),
    ]);
  }
}
