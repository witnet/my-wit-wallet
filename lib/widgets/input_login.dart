import 'package:flutter/material.dart';
import 'package:witnet_wallet/theme/extended_theme.dart';


class InputLogin extends StatefulWidget {
  InputLogin({
    Key? key,
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
  });
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
  @override
  _InputLoginState createState() => _InputLoginState();
}

typedef StringCallback = void Function(String?);
typedef BlankCallback = void Function();
typedef PointerDownCallback = void Function(PointerDownEvent?);


class _InputLoginState extends State<InputLogin> {
  bool showPassword = false;

  handleShowPass() {
    return IconButton(
      icon: showPassword
          ? Icon(Icons.remove_red_eye, size: 20)
          : Icon(Icons.visibility_off, size: 20),
      onPressed: () {
        setState(() => showPassword = !showPassword);
      },
    );
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = Theme.of(context).extension<ExtendedTheme>()!;
    return Container(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: widget.hint ?? 'Input your password',
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
          suffixIcon: IconButton(
            splashRadius: 1,
            padding: const EdgeInsets.all(2),
            color: extendedTheme.inputIconColor,
            iconSize: theme.iconTheme.size,
            icon: showPassword
                ? Icon(Icons.remove_red_eye)
                : Icon(Icons.visibility_off),
            onPressed: () {
              setState(() => showPassword = !showPassword);
            },
          ),
        ),
        minLines: 1,
        style: theme.textTheme.bodyLarge,
        autocorrect: false,
        focusNode: widget.focusNode,
        controller: widget.textEditingController,
        obscureText: widget.obscureText ? !showPassword : false,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged ?? (String? value){},
        onEditingComplete: widget.onEditingComplete ?? () {},
        onFieldSubmitted: widget.onFieldSubmitted ?? (String? value) {},
        onTapOutside: widget.onTapOutside ?? (PointerDownEvent? event) {},
        onTap: widget.onTap?? () {},
        validator: widget.validator,
      ),
    );
  }
}
