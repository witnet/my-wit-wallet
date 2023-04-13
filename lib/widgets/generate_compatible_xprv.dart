import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _passConfirmFocusNode = FocusNode();
final _passConfirmController = TextEditingController();

typedef void StringCallback(String? value);

class GenerateCompatibleXprv extends StatefulWidget {
  final StringCallback onXprvGenerated;
  GenerateCompatibleXprv({
    Key? key,
    required this.onXprvGenerated,
  }) : super(key: key);
  GenerateCompatibleXprvState createState() => GenerateCompatibleXprvState();
}

class GenerateCompatibleXprvState extends State<GenerateCompatibleXprv>
    with TickerProviderStateMixin {
  String _password = '';
  String _confirmPassword = '';
  String? errorText;

  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  @override
  void initState() {
    super.initState();
    _passController.clear();
    _passConfirmController.clear();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ignore: todo
  // TODO[#24]: Use formz model to validate password

  bool validate({bool force = false}) {
    if (this.mounted) {
      if (force ||
          (!_passConfirmFocusNode.hasFocus && !_passFocusNode.hasFocus)) {
          if (_password.isEmpty && _confirmPassword.isEmpty) {
            setState(() {
              errorText = 'Please input a password';
            });
            return false;
          } else if (_password == _confirmPassword) {
            setState(() {
              errorText = null;
            });
            return true;
          } else {
            setState(() {
              errorText = 'Password Mismatch';
            });
            return false;
          }
        }
       else {
        setState(() {
          errorText = null;
        });
        return false;
      }
    }
    return false;
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _passConfirmFocusNode.addListener(() => validate());
    _passFocusNode.addListener(() => validate());

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PLEASE NOTE:',
          style: theme.textTheme.headline3,
        ),
        SizedBox(height: 8),
        Text(
          'This password encrypts your xprv file. You will be asked to type this password if you want to import this file as a backup.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: theme.textTheme.subtitle2,
              ),
              SizedBox(height: 8),
              InputLogin(
                prefixIcon: Icons.lock,
                hint: 'Password',
                focusNode: _passFocusNode,
                textEditingController: _passController,
                obscureText: true,
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _password = value!;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              Text(
                'Confirm password',
                style: theme.textTheme.subtitle2,
              ),
              SizedBox(height: 8),
              InputLogin(
                prefixIcon: Icons.lock,
                hint: 'Confirm Password',
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                textEditingController: _passConfirmController,
                errorText: errorText,
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _confirmPassword = value!;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: 'Generate xprv',
                  type: 'primary',
                  enabled: true,
                  onPressed: () => {
                        if (validate(force: true))
                          {
                            // TODO: generate valid xprv
                            // TODO: add loading state
                            widget.onXprvGenerated('XPRV example'),
                          }
                      }),
            ],
          ),
        ),
      ],
    );
  }
}
