import 'package:flutter/material.dart';

class PaddedButton extends StatelessWidget {
  PaddedButton(
      {required this.padding, required this.text, required this.onPressed});

  final EdgeInsets padding;
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 30),
        ),
        child: Text(text),
        onPressed: onPressed,
      ),
    );
  }
}
