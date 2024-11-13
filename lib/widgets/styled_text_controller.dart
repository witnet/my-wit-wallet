import 'package:flutter/material.dart';

class StyledTextController extends TextEditingController {
  TextStyle? normalStyle;
  TextStyle? selectStyle;
  bool obscureText;
  String? obscureChar;
  bool wordCheck;
  StyledTextController({
    this.normalStyle,
    this.selectStyle,
    this.obscureChar,
    this.obscureText = false,
    this.wordCheck = false,
  });

  void setStyle(TextStyle normalStyle, TextStyle selectStyle) {
    this.normalStyle = normalStyle;
    this.selectStyle = selectStyle;
  }

  void _addSpan(
      List<InlineSpan> textList, int start, int end, TextStyle style) {
    textList.add(TextSpan(
        text: obscureText
            ? List<String>.generate(text.length, (index) => obscureChar ?? '•')
                .join()
                .substring(start, end)
            : text.substring(start, end),
        style: style));
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final theme = Theme.of(context);
    selectStyle = selectStyle ?? theme.textTheme.bodyMedium;
    normalStyle = normalStyle ?? theme.textTheme.bodyMedium;
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    // Check if there is an active selection in the text.
    if (selection.start != selection.end) {
      // Add unselected text before the selection, if any.
      if (selection.start != 0) {
        _addSpan(textSpanChildren, 0, selection.start, normalStyle!);
      }
      // Add the selected text with the selected style.
      _addSpan(textSpanChildren, selection.start, selection.end, selectStyle!);
      // Add any unselected text after the selection.
      if (text.length > selection.end) {
        _addSpan(textSpanChildren, selection.end, text.length, normalStyle!);
      }
    } else {
      // If no text is selected, apply normal style to the entire text.
      _addSpan(textSpanChildren, 0, text.length, normalStyle!);
    }
    return TextSpan(style: style, children: textSpanChildren);
  }
}
