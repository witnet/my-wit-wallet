import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/input_text.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';

class InputPassword extends InputText {
  InputPassword(
      {required this.showPassFocusNode,
        IconData? autoFocusIconData,
        IconData? prefixIcon,
        required FocusNode focusNode,
        String? errorText,
        String? Function(String?)? validator,
        String? hint,
        TextInputType? keyboardType,
        required StyledTextController styledTextController,
        bool obscureText = false,
        void Function(String)? onChanged,
        void Function()? onEditingComplete,
        void Function(String)? onFieldSubmitted,
        void Function(PointerDownEvent)? onTapOutside,
        void Function()? onTap,
        void Function()? onSuffixTap,
        List<TextInputFormatter>? inputFormatters})
      : super(
    prefixIcon: prefixIcon,
    focusNode: focusNode,
    errorText: errorText,
    validator: validator,
    hint: hint,
    keyboardType: keyboardType,
    styledTextController: styledTextController,
    obscureText: obscureText,
    onChanged: onChanged,
    onEditingComplete: onEditingComplete,
    onFieldSubmitted: onFieldSubmitted,
    onTapOutside: onTapOutside,
    onTap: onTap,
    onSuffixTap: onSuffixTap,
    inputFormatters: inputFormatters,
  );
  final FocusNode? showPassFocusNode;
  @override
  _InputLoginState createState() => _InputLoginState();
}

typedef StringCallback = void Function(String?);
typedef BlankCallback = void Function();
typedef PointerDownCallback = void Function(PointerDownEvent?);

class _InputLoginState extends State<InputPassword> {
  bool showPassword = false;
  bool showPasswordFocus = false;

  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
    if (widget.showPassFocusNode != null && this.mounted)
      widget.showPassFocusNode!.addListener(_onFocusChange);
  }

  void dispose() {
    super.dispose();
    widget.focusNode.removeListener(_onFocusChange);
  }

  _onFocusChange() {
    if (!widget.focusNode.hasFocus) {
      int offset = widget.styledTextController.selection.baseOffset;
      widget.styledTextController.selection = TextSelection.collapsed(
          offset: offset, affinity: TextAffinity.upstream);
    }
    setState(() {
      showPasswordFocus = widget.showPassFocusNode!.hasFocus;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    widget.styledTextController.setStyle(
      theme.textTheme.bodyLarge!,
      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
    );
    return Container(
        child: Semantics(
      textField: true,
      label: localization.inputYourPassword,
      child: widget.buildInput( context: context,
        decoration: InputDecoration(
            suffixIconConstraints: BoxConstraints(minWidth: 50),
            hintText: widget.hint ?? localization.inputYourPassword,
            errorText: widget.errorText,
            prefixIcon:
                widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
            suffixIcon: Semantics(
              label: localization.showPassword,
              child: SuffixIcon(
                  iconSize: theme.iconTheme.size,
                  icon: showPassword
                      ? Icons.remove_red_eye
                      : Icons.visibility_off,
                  focusNode: widget.showPassFocusNode ?? FocusNode(),
                  onPressed: () {
                    setState(() => showPassword = !showPassword);
                    widget.styledTextController.obscureText = !showPassword;
                  },
                  isFocus: (widget.showPassFocusNode != null &&
                      widget.showPassFocusNode!.hasFocus)),
            )),
      ),
    ));
  }
}
