import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/test/test_card.dart';
import 'package:my_wit_wallet/widgets/layouts/layout.dart';

class TestScreen extends StatefulWidget {
  static final route = '/test';
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      navigationActions: [],
      widgetList: [
        _body(),
      ],
      actions: [],
    );
  }

  _body() {
    return Center(
      child: TestCard(),
    );
  }
}
