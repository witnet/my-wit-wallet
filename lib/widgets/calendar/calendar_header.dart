import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalendarHeader extends StatelessWidget {

  CalendarHeader({
  required this.title,
    required this.showHeader,
    required this.onLeftBtnPressed,
    required this.onRightBtnPressed,
});


  final String title;
  final bool showHeader;
  final VoidCallback onLeftBtnPressed;
  final VoidCallback onRightBtnPressed;

  Widget _leftButton() => IconButton(
      onPressed: onLeftBtnPressed,
      icon: Icon(FontAwesomeIcons.arrowLeft)
  );
  Widget _rightButton() => IconButton(
      onPressed: onRightBtnPressed,
      icon: Icon(FontAwesomeIcons.arrowRight)
  );

  @override
  Widget build(BuildContext context) =>
    showHeader ? Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _leftButton(),
          _rightButton(),
        ],
      ),
    ) : Container();

  
}