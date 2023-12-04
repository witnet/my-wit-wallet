import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/widgets/suffix_icon_button.dart';

class InputLogin extends StatefulWidget {
  InputLogin(
      {Key? key,
      this.prefixIcon,
      this.hint,
      this.keyboardType,
      this.obscureText = false,
      this.textEditingController,
      this.validator,
      this.errorText,
      this.focusNode,
      this.onChanged,
      this.onEditingComplete,
      this.onFieldSubmitted,
      this.onTapOutside,
      this.onTap,
      this.showPassFocusNode,
      this.autoFocus = false});
  final IconData? prefixIcon;
  final FocusNode? focusNode;
  final String? errorText;
  final String? Function(String?)? validator;
  final String? hint;
  final TextInputType? keyboardType;
  final TextEditingController? textEditingController;
  final bool obscureText;
  final StringCallback? onChanged;
  final BlankCallback? onEditingComplete;
  final StringCallback? onFieldSubmitted;
  final PointerDownCallback? onTapOutside;
  final BlankCallback? onTap;
  final FocusNode? showPassFocusNode;
  final bool autoFocus;
  @override
  _InputLoginState createState() => _InputLoginState();
}

typedef StringCallback = void Function(String?);
typedef BlankCallback = void Function();
typedef PointerDownCallback = void Function(PointerDownEvent?);

class _InputLoginState extends State<InputLogin> {
  bool showPassword = false;
  bool showPasswordFocus = false;

  void initState() {
    super.initState();
    if (widget.showPassFocusNode != null && this.mounted)
      widget.showPassFocusNode!.addListener(_onFocusChange);
  }

  void dispose() {
    super.dispose();
  }

  _onFocusChange() {
    setState(() {
      showPasswordFocus = widget.showPassFocusNode!.hasFocus;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        child: Semantics(
      textField: true,
      label: localization.inputYourPassword,
      child: TextFormField(
        decoration: InputDecoration(
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
                  },
                  isFocus: (widget.showPassFocusNode != null &&
                      widget.showPassFocusNode!.hasFocus)),
            )),
        minLines: 1,
        style: theme.textTheme.bodyLarge,
        autocorrect: false,
        autofocus: widget.autoFocus,
        focusNode: widget.focusNode,
        controller: widget.textEditingController,
        obscureText: widget.obscureText ? !showPassword : false,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged ?? (String? value) {},
        onEditingComplete: widget.onEditingComplete ?? () {},
        onFieldSubmitted: widget.onFieldSubmitted ?? (String? value) {},
        onTapOutside: widget.onTapOutside ?? (PointerDownEvent? event) {},
        onTap: widget.onTap ?? () {},
        validator: widget.validator,
      ),
    ));
  }
}
