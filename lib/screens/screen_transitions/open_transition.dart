import 'package:flutter/material.dart';

class OpenAndFadeTransition extends MaterialPageRoute {
  final Widget secondPage;

  OpenAndFadeTransition(this.secondPage)
      : super(builder: (context) => secondPage);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
