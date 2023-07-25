import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/screens/login/view/login_screen.dart';
import 'package:my_wit_wallet/screens/screen_transitions/fade_transition.dart';

class TestCard extends StatefulWidget {
  TestCard({Key? key}) : super(key: key);
  TestCardState createState() => TestCardState();
}

class TestCardState extends State<TestCard> with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final cardWidth = min(deviceSize.width * 0.95, 360.0);
    const cardPadding = 10.0;
    return FittedBox(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(
                  left: cardPadding,
                  right: cardPadding,
                  top: cardPadding + 10,
                ),
                width: cardWidth,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10),
                      backButton(context),
                    ])),
          ],
        ),
      ),
    );
  }

  PaddedButton backButton(BuildContext context) {
    return PaddedButton(
        padding: EdgeInsets.all(5),
        text: 'Back',
        type: ButtonType.primary,
        onPressed: () => Navigator.pushReplacement(
              context,
              FadeRoute(page: LoginScreen()),
            ));
  }
}
