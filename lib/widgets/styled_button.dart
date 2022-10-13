import 'package:flutter/material.dart';

class StyledButton extends MaterialButton {
  StyledButton({
    Key? key,
    required this.style,
    required this.onPressed,
    required this.minimumSize,
    required this.child,
    this.isLoading = false,
  }) : super(key: key, onPressed: onPressed);

  final bool isLoading;
  final VoidCallback onPressed;
  final Size minimumSize;
  final ButtonStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return ButtonTheme(
      buttonColor: theme.colorScheme.secondary,
      minWidth: minWidth ?? size.width * 0.316,
      height: height ?? size.height * 0.053,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          minimumSize: Size(double.infinity,
              30), // double.infinity is the width and 30 is the height
        ),
        child: isLoading
            ? FittedBox(
                fit: BoxFit.cover,
                child: Row(
                  children: <Widget>[child],
                ),
              )
            : child,
        onPressed: onPressed,
      ),
    );
  }
}
