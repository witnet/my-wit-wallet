import 'dart:developer';

import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/password.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();

typedef void VoidCallback(Xprv? value);

class VerifyPassword extends StatefulWidget {
  final VoidCallback onXprvGenerated;
  VerifyPassword({
    Key? key,
    required this.onXprvGenerated,
  }) : super(key: key);
  VerifyPasswordState createState() => VerifyPasswordState();
}

class VerifyPasswordState extends State<VerifyPassword>
    with TickerProviderStateMixin {
  String _password = '';
  Xprv? xprv;
  String? errorText;
  String? localEncryptedXprv =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv;

  void setPassword(String password) {
    setState(() {
      _password = password;
    });
  }

  @override
  void initState() {
    super.initState();
    _passController.clear();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool validPassword() {
    try {
      setState(() => {
            xprv = Xprv.fromEncryptedXprv(
                localEncryptedXprv ?? '', Password.hash(_password))
          });
      return true;
    } catch (e) {
      return false;
    }
  }

  // ignore: todo
  // TODO[#24]: Use formz model to validate password

  bool validate({bool force = false}) {
    if (this.mounted) {
      if (force || !_passFocusNode.hasFocus) {
        setState(() {
          errorText = null;
        });
        if (_password.isEmpty) {
          setState(() {
            errorText = 'Please input your wallet password';
          });
        } else if (!validPassword()) {
          setState(() {
            errorText = 'Wrong password';
          });
        }
      }
    }
    return errorText != null ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    _passFocusNode.addListener(() => validate());

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Please, input your wallet\'s password.',
          style: theme.textTheme.bodyText1,
        ),
        SizedBox(height: 16),
        Form(
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
                hint: 'Password',
                obscureText: true,
                focusNode: _passFocusNode,
                textEditingController: _passController,
                errorText: errorText,
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _password = value!;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: 'Verify',
                  type: 'primary',
                  enabled: true,
                  onPressed: () => {
                        validate(force: true),
                        if (xprv != null)
                          {
                            widget.onXprvGenerated(xprv),
                          }
                      }),
            ],
          ),
        ),
      ],
    );
  }
}
