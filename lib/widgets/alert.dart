import 'package:flutter/material.dart';

class Alert extends AlertDialog {
  final String titleText;
  final String contentText;

  Alert({required this.titleText, required this.contentText});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 5,
      title: Text(titleText),
      content: Text(contentText),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Ok'),
        )
      ],
    );
  }
}