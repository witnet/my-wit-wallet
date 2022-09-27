import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/login/view/login_form.dart';
import 'package:witnet_wallet/theme/wallet_theme.dart';
import 'package:witnet_wallet/widgets/layout.dart';

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
          FittedBox(
            alignment: Alignment.topCenter,
            child: Container(
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 230),
                reverseDuration: const Duration(microseconds: 1100),
                child: LoginForm(),
                transitionBuilder:
                    (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    child: child,
                    opacity: animation,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ]);
  }
}
