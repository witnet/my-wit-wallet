import 'package:flutter/material.dart';

typedef String? StringCallback(String? value);
typedef void BlankCallback();

class PasswordInput extends StatefulWidget {
  final String textLabel;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final bool obscureText = true;
  final StringCallback validator;
  final StringCallback onChanged;
  final StringCallback onSubmitted;
  final BlankCallback onEditingComplete;

  PasswordInput(
    this.textLabel, {
    required this.focusNode,
    required this.textEditingController,
    required this.validator,
    required this.onChanged,
    required this.onSubmitted,
    required this.onEditingComplete,
  });

  @override
  PasswordInputState createState() => PasswordInputState();
}

class PasswordInputState extends State<PasswordInput> {
  bool showPassword = false;
  Widget toggleObscureButton() {
    return IconButton(
      icon: showPassword
          ? Icon(Icons.remove_red_eye, size: 20)
          : Icon(Icons.visibility_off, size: 20),
      onPressed: () {
        setState(() => showPassword = !showPassword);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            //Icon(FontAwesomeIcons.lock),
            //SizedBox(width: 5,),
            Flexible(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: widget.textLabel,
                  errorText:
                      widget.validator(widget.textEditingController.text),
                ),
                focusNode: widget.focusNode,
                controller: widget.textEditingController,
                obscureText: widget.obscureText ? !showPassword : false,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onEditingComplete: widget.onEditingComplete,
              ),
            ),
            toggleObscureButton(),
          ],
        ),
      ),
    );
  }
}
