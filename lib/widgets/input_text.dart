import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';

typedef StringCallback = void Function(String);
typedef BlankCallback = void Function();
typedef PointerDownCallback = void Function(PointerDownEvent);

abstract class InputText extends StatefulWidget {
  InputText({
    Key? key,
    this.prefixIcon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    required this.styledTextController,
    this.validator,
    this.errorText,
    required this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onTapOutside,
    this.onTap,
    this.onSuffixTap,
    this.suffixText,
    this.suffixIconConstraints,
    this.decoration,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines,
    this.minLines,
  });
  final IconData? prefixIcon;
  final FocusNode focusNode;
  final String? errorText;
  final String? Function(String?)? validator;
  final String? hint;
  final String? suffixText;
  final BoxConstraints? suffixIconConstraints;
  final TextInputType? keyboardType;
  final StyledTextController styledTextController;
  final bool obscureText;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;
  final void Function(PointerDownEvent)? onTapOutside;
  final void Function()? onTap;
  final void Function()? onSuffixTap;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;

  Widget buildInput(
      {required BuildContext context, InputDecoration? decoration = null}) {
    return TextFormField(
      decoration: decoration ?? decoration,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autocorrect: false,
      focusNode: focusNode,
      controller: styledTextController,
      onChanged: onChanged ?? (String? value) {},
      onEditingComplete: onEditingComplete ?? () {},
      onFieldSubmitted: onFieldSubmitted ?? (String? value) {},
      onTapOutside: onTapOutside ?? (PointerDownEvent? event) {},
      onTap: onTap ?? () {},
      validator: validator,
      textInputAction: textInputAction ?? null,
    );
  }

  void onFocusChange() {
    final int offset = styledTextController.selection.baseOffset;
    final TextSelection collapsed = TextSelection.collapsed(
      offset: offset,
      affinity: TextAffinity.upstream,
    );
    if (!focusNode.hasFocus) {
      styledTextController.selection = collapsed;
    }
  }
}
