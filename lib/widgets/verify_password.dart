import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/PaddedButton.dart';
import 'package:my_wit_wallet/widgets/input_login.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/validations/password_valid_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

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
  VerifyPasswordInput _password = VerifyPasswordInput.pure();
  bool isLoading = false;
  String? validPasswordError;
  String? xprv;
  String? localEncryptedXprv =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet.xprv;
  ValidationUtils validationUtils = ValidationUtils();
  List<FocusNode> _formFocusElements = [_passFocusNode];

  AppLocalizations get _localization => AppLocalizations.of(context)!;

  void setPassword(String password, {bool? validate}) {
    setState(() {
      _password = VerifyPasswordInput.dirty(
          value: password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus(_formFocusElements));
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

  Future<String?> decryptedXprv() async {
    ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
    String? xprvDecripted;
    try {
      String hashPassword =
          await apiCrypto.hashPassword(password: _password.value);
      xprvDecripted = await apiCrypto.decryptXprv(
          xprv: localEncryptedXprv ?? '', password: hashPassword);
      setState(() => xprv = xprvDecripted);
      return xprvDecripted;
    } catch (e) {
      return null;
    }
  }

  bool formValidation() {
    return _password.isValid;
  }

  Future<bool> validateForm({force = false}) async {
    if (force) {
      _password = VerifyPasswordInput.dirty(
          value: _password.value,
          allowValidation: true,
          decriptedXprv: await decryptedXprv());
    }
    return formValidation();
  }

  Future<void> _verify() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    if (await validateForm(force: true)) {
      widget.onXprvGenerated(xprv);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    _passFocusNode.addListener(() => validateForm());
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localization.inputPasswordPrompt,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                obscureText: true,
                focusNode: _passFocusNode,
                showPassFocusNode: _showPasswordFocusNode,
                textEditingController: _passController,
                errorText: _password.error ?? validPasswordError,
                onFieldSubmitted: (String? value) async {
                  FocusManager.instance.primaryFocus?.unfocus();
                  await _verify();
                },
                onChanged: (String? value) {
                  setPassword(value ?? '');
                },
              ),
              SizedBox(height: 16),
              PaddedButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: _localization.verifyLabel,
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
