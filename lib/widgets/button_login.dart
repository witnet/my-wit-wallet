import 'package:flutter/material.dart';

class ButtonLogin extends MaterialButton {
  ButtonLogin({
    Key? key,
    this.label = 'OK',
    required this.onPressed,
    this.isLoading = false,
    this.height,
    this.minWidth,
  }) : super(key: key, onPressed: onPressed);
  final minWidth;
  final height;
  final bool isLoading;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return ButtonTheme(
      buttonColor: theme.accentColor,
      minWidth: minWidth ?? size.width * 0.316,
      height: height ?? size.height * 0.053,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: theme.primaryColor,
          minimumSize: Size(double.infinity,
              30), // double.infinity is the width and 30 is the height
        ),
        child: isLoading
            ? FittedBox(
                fit: BoxFit.cover,
                child: Row(
                  children: <Widget>[
                    Text(
                      label,
                    ),
                  ],
                ),
              )
            : Text(
                label,
              ),
        onPressed: onPressed,
      ),
    );
  }
}
