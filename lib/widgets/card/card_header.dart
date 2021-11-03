import 'package:flutter/material.dart';

class CardHeader extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  CardHeader({
    Key? key,
    required this.title,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      width: width,
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0))),
      child: Padding(
        padding: EdgeInsets.only(top: 1),
        child: Text(
          title,
          style: theme.textTheme.headline4,
        ),
      ),
    );
  }
}
