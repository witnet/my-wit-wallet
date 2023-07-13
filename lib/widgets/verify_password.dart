import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';

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
                errorText: errorText,
                onFieldSubmitted: (String? value) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _verify();
                },
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
                    await _verify();
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
