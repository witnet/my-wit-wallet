import 'dart:async';
import 'package:formz/formz.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/validations/confirmed_password.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';

final _passController = TextEditingController();
final _passFocusNode = FocusNode();
final _passConfirmFocusNode = FocusNode();
final _showPassFocusNode = FocusNode();
final _showPassConfirmFocusNode = FocusNode();
final _passConfirmController = TextEditingController();

typedef void StringCallback(String? value);

class GenerateCompatibleXprv extends StatefulWidget {
  final StringCallback onXprvGenerated;
  final String? xprv;
  GenerateCompatibleXprv({
    Key? key,
    required this.onXprvGenerated,
    this.xprv,
  }) : super(key: key);
  GenerateCompatibleXprvState createState() => GenerateCompatibleXprvState();
}

class GenerateCompatibleXprvState extends State<GenerateCompatibleXprv>
    with TickerProviderStateMixin {
  PasswordInput? _password;
  ConfirmedPassword? _confirmPassword;
  bool isLoading = false;
  String? errorText;
  String? localEncryptedXprv =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv;
  String? compatibleXprv;

  void setPassword(String password) {
    setState(() {
      _password = PasswordInput.dirty(value: password);
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

  Future _generateSheikahCompatibleXprv(password) async {
    ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
    String xprvGenerated;
    if (widget.xprv != null) {
      try {
        xprvGenerated =
            await apiCrypto.encryptXprv(xprv: widget.xprv!, password: password);
        setState(() => compatibleXprv = xprvGenerated);
        widget.onXprvGenerated(compatibleXprv);
      } catch (e) {
        print(e);
      }
    }
  }

  bool validate({bool force = false}) {
    if (this.mounted) {
      setState(() {
        errorText = null;
      });
      if (force ||
          (!_passConfirmFocusNode.hasFocus &&
              !_passFocusNode.hasFocus &&
              !_showPassFocusNode.hasFocus &&
              !_showPassConfirmFocusNode.hasFocus)) {
        if (_password != null && _confirmPassword != null) {
          final validInputs = <FormzInput>[
            _password!,
            _confirmPassword!,
          ];
          return Formz.validate(validInputs).isValid;
        }
      } else {
        return false;
      }
    }
    return false;
  }

  Future<void> _loadAndgenerateSheikahXprv() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    if (validate(force: true)) {
      await _generateSheikahCompatibleXprv(_password!.value);
    }
    setState(() => isLoading = false);
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
          'This password encrypts your xprv file. You will be asked to type this password if you want to import this xprv as a backup.',
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
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
                focusNode: _passFocusNode,
                errorText: _password?.error ?? null,
                showPassFocusNode: _showPassFocusNode,
                textEditingController: _passController,
                obscureText: true,
                onFieldSubmitted: (String? value) {
                  _passConfirmFocusNode.requestFocus();
                },
                onTap: () {
                  _passFocusNode.requestFocus();
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
              Text(
                'Confirm password',
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: 'Confirm Password',
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                showPassFocusNode: _showPassConfirmFocusNode,
                textEditingController: _passConfirmController,
                errorText: _confirmPassword?.error ?? null,
                onFieldSubmitted: (String? value) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _loadAndgenerateSheikahXprv();
                },
                onTap: () {
                  _passConfirmFocusNode.requestFocus();
                },
                onChanged: (String? value) {
                  if (this.mounted) {
                    setState(() {
                      _confirmPassword = ConfirmedPassword.dirty(
                          original: _password ?? PasswordInput.dirty(value: ''),
                          value: value!);
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: 'Generate xprv',
                  type: ButtonType.primary,
                  isLoading: isLoading,
                  enabled: true,
                  onPressed: () async {
                    await _loadAndgenerateSheikahXprv();
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
