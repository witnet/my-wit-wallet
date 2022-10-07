import 'package:flutter/material.dart';
import 'package:witnet_wallet/screens/test/test_card.dart';
import 'package:witnet_wallet/widgets/layout.dart';

class TestScreen extends StatefulWidget {
  static final route = '/test';
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Layout(
      headerActions: [],
      widgetList: [
        _body(),
      ],
      actions: [],
      actionsSize: 0,
    );
  }

  _body() {
    return Center(
      child: TestCard(),
    );
  }
}
