import 'package:flutter/material.dart';

class DecorationsLogin {
  static BoxDecoration borderInput = BoxDecoration(
    borderRadius: BorderRadius.circular(7.0),
    border: Border.all(color: Colors.white10, width: 1.0),
  );

  static InputDecoration inputDecorationLogin(
      {required prefixIcon, suffixIcon, hint = 'your test', label = 'test'}) {
    return InputDecoration(
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      hintText: hint,
      labelText: label,
      hintStyle: TextStyle(fontSize: 15.0, color: Colors.white54),
      labelStyle: TextStyle(fontSize: 15.0, color: Colors.white60),
    );
  }
}

class TextStylesLogin {
  static TextStyle textLink = TextStyle(
      fontSize: 12,
      color: Colors.white70,
      decoration: TextDecoration.underline);
  static TextStyle textLinkDark = TextStyle(
      fontSize: 16,
      color: Colors.black54,
      decoration: TextDecoration.underline);
}
