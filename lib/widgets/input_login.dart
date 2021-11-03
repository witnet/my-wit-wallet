import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class InputLogin extends StatefulWidget {
  InputLogin({
    this.prefixIcon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.textEditingController,
    this.validator,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
  });
  final focusNode;
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

  String? _validator(value) {
    if (widget.obscureText) {
      if (value == null || value.isEmpty) {
        return 'type a ${widget.hint}';
      }
      return null;
    } else {
      if (value == null || value.isEmpty) {
        return 'type a ${widget.hint}';
      }
      return null;
    }
  }

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
    final size = MediaQuery.of(context).size;
    return Container(
      height: (size.height) * 0.056,
      // /width: (size.width) * 0.74,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Icon(widget.prefixIcon),
            Flexible(
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                minLines: 1,
                focusNode: widget.focusNode,
                controller: widget.textEditingController,
                obscureText: widget.obscureText ? !showPassword : false,
                keyboardType: widget.keyboardType,
                onChanged: widget.onChanged,
                onEditingComplete: widget.onEditingComplete,
              ),
            ),
            widget.obscureText ? handleShowPass() : Container(),
          ],
        ),
      ),
    );
  }
}
