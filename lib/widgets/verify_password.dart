import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _showPasswordFocusNode = FocusNode();

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
  PasswordInput? _password;
  bool isLoading = false;
  bool isValidPassword = false;
  String? validPasswordError;
  String? xprv;
  String? localEncryptedXprv =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv;

  void setPassword(String password) {
    setState(() {
      _password = PasswordInput.dirty(value: password);
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
      String hashPassword =
          await apiCrypto.hashPassword(password: _password!.value);
      xprvDecripted = await apiCrypto.decryptXprv(
          xprv: localEncryptedXprv ?? '', password: hashPassword);
      setState(() => {xprv = xprvDecripted, isValidPassword = true});
    } catch (e) {
      setState(() => isValidPassword = false);
    }
  }

  bool validate({bool force = false}) {
    if (this.mounted) {
      setState(() {
        validPasswordError = null;
      });
      if (force || !_passFocusNode.hasFocus) {
        if (_password != null && _password!.invalid) {
          setState(() {
            if (force) isLoading = false;
          });
        } else if (force && !isValidPassword) {
          setState(() {
            validPasswordError = 'Wrong password';
            isLoading = false;
          });
        }
      }
    }
    return validPasswordError == null && (_password!.valid) ? true : false;
  }

  Future<void> _verify() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    await validatePassword();
    if (validate(force: true)) {
      widget.onXprvGenerated(xprv);
    }
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
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: 'Password',
                obscureText: true,
                focusNode: _passFocusNode,
                showPassFocusNode: _showPasswordFocusNode,
                textEditingController: _passController,
                errorText: _password?.error ?? validPasswordError,
                onFieldSubmitted: (String? value) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _verify();
                },
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _password = PasswordInput.dirty(value: value!);
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: 'Verify',
                  isLoading: isLoading,
                  type: ButtonType.primary,
                  enabled: true,
                  onPressed: () async {
                    await _verify();
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
