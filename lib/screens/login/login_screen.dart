import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/login/create_or_recover_card.dart';
import 'package:witnet_wallet/screens/login/login_card.dart';
import 'package:witnet_wallet/widgets/svg_widget.dart';

class LoginScreen extends StatefulWidget {
  static final route = '/login';

  LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  var size;
  dynamic currentCard;

  @override
  void initState() {
    super.initState();

    currentCard = LoginCard(onCreateOrRecover: switchToCreateOrRecoverCard);
  }

  void switchToCreateOrRecoverCard() {
    setState(() {
      currentCard = CreateOrRecoverCard(onBack: switchToLoginCard);
    });
  }

  void switchToLoginCard() {
    setState(() {
      currentCard = LoginCard(onCreateOrRecover: switchToCreateOrRecoverCard);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: new GestureDetector(
        onTap: () {
/*This method here will hide the soft keyboard.*/
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          child:
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: size.height * 0.25,
                    width: size.width ,
                    child: Image(image:AssetImage('assets/img/witnet_logo.png')),
                  ),
                  FittedBox(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 230),
                        reverseDuration: const Duration(microseconds: 1100),
                        child: currentCard,
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
          ),
        ),
      );
  }
}
