import 'dart:async';
import 'package:formz/formz.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/validations/confirmed_password.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

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
  PasswordInput _password = PasswordInput.pure();
  ConfirmedPassword _confirmPassword = ConfirmedPassword.pure();
  bool isLoading = false;
  String? errorText;
  String? localEncryptedXprv =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv;
  String? compatibleXprv;
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements = [
    _passConfirmFocusNode,
    _passFocusNode,
    _showPassFocusNode,
    _showPassConfirmFocusNode
  ];

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  void setPassword(String password, {bool? validate}) {
    setState(() {
      _password = PasswordInput.dirty(
          value: password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements));
    });
  }

  void setConfirmPassword(String password, {bool? validate}) {
    setState(() {
      _confirmPassword = ConfirmedPassword.dirty(
          value: password,
          original: _password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements));
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

  bool formValidation() {
    final validInputs = <FormzInput>[
      _password,
      _confirmPassword,
    ];
    return Formz.validate(validInputs);
  }

  bool validateForm({force = false}) {
    if (force && this.mounted) {
      setPassword(_password.value, validate: true);
      setConfirmPassword(_confirmPassword.value, validate: true);
    }
    return formValidation();
  }

  Future<void> _loadAndgenerateSheikahXprv() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    if (validateForm(force: true)) {
      await _generateSheikahCompatibleXprv(_password.value);
    }
    setState(() => isLoading = false);
  }

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    _passConfirmFocusNode.addListener(() => validateForm());
    _passFocusNode.addListener(() => validateForm());

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localization.passwordDescription,
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
                _localization.passwordLabel,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: _localization.passwordLabel,
                focusNode: _passFocusNode,
                errorText: _password.error,
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
                  setPassword(value ?? '');
                },
              ),
              SizedBox(height: 16),
              Text(
                _localization.confirmPassword,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: 8),
              InputLogin(
                hint: _localization.confirmPassword,
                obscureText: true,
                focusNode: _passConfirmFocusNode,
                showPassFocusNode: _showPassConfirmFocusNode,
                textEditingController: _passConfirmController,
                errorText: _confirmPassword.error,
                onFieldSubmitted: (String? value) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _loadAndgenerateSheikahXprv();
                },
                onTap: () {
                  _passConfirmFocusNode.requestFocus();
                },
                onChanged: (String? value) {
                  setConfirmPassword(value ?? '');
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: _localization.generateXprv,
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
