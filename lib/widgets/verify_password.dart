import 'dart:developer';

import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/encrypt/password.dart';
import 'package:witnet_wallet/widgets/PaddedButton.dart';
import 'package:witnet_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();

typedef void VoidCallback(String? value);

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
  bool isLoading = false;
  bool isValidPassword = false;
  String? xprv;
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

  Future validatePassword() async {
    ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
    String? xprvDecripted;
    try {
      String hashPassword = await apiCrypto.hashPassword(password: _password);
      xprvDecripted = await apiCrypto.decryptXprv(
          xprv: localEncryptedXprv ?? '', password: hashPassword);
      setState(() => {xprv = xprvDecripted, isValidPassword = true});
    } catch (e) {
      setState(() => isValidPassword = false);
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
            if (force) isLoading = false;
          });
        } else if (force && !isValidPassword) {
          setState(() {
            errorText = 'Wrong password';
            isLoading = false;
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
                  isLoading: isLoading,
                  type: 'primary',
                  enabled: true,
                  onPressed: () async {
                    if (isLoading) return;
                    setState(() => isLoading = true);
                    await validatePassword();
                    if (validate(force: true)) {
                      widget.onXprvGenerated(xprv);
                    }
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
