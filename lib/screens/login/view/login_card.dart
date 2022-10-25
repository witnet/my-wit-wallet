import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/login/view/login_form.dart';

class LoginCard extends StatefulWidget {
  LoginCard({
    Key? key,
    required this.onCreateOrRecover,
  }) : super(key: key);

  final Function onCreateOrRecover;
  @override
  LoginCardState createState() => LoginCardState();
}

class LoginCardState extends State<LoginCard> with TickerProviderStateMixin {
  late String selectedWallet;
  String password = '';
  var size;
  static const loadingDuration = Duration(milliseconds: 400);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: LoginForm(),
        ),
      ],
    );
  }
}
