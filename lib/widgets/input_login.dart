import 'package:flutter/material.dart';

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
  });
  final focusNode;
  final errorText;
  final validator;
  final prefixIcon;
  final hint;
  final keyboardType;
  final textEditingController;
  final obscureText;
  final StringCallback? onChanged;
  final BlankCallback? onEditingComplete;

  @override
  _InputLoginState createState() => _InputLoginState();
}

typedef void StringCallback(String? value);
typedef void BlankCallback();

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
    return Container(
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'Input your password',
          errorText: widget.errorText,
          suffixIcon: IconButton(
            splashRadius: 1,
            padding: const EdgeInsets.all(2),
            color: theme.iconTheme.color,
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
        style: theme.textTheme.bodyText1,
        autocorrect: false,
        focusNode: widget.focusNode,
        controller: widget.textEditingController,
        obscureText: widget.obscureText ? !showPassword : false,
        keyboardType: widget.keyboardType,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        validator: widget.validator,
      ),
    );
  }
}
