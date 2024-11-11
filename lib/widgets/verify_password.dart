import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/buttons/custom_btn.dart';
import 'package:my_wit_wallet/widgets/input_password.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/labeled_form_entry.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';
import 'package:my_wit_wallet/widgets/validations/password_valid_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

final _passController = StyledTextController();
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
          localization.inputPasswordPrompt,
          style: theme.textTheme.bodyLarge,
        ),
        SizedBox(height: 16),
        Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledFormEntry(
                label: localization.passwordLabel,
                formEntry: InputPassword(
                  hint: localization.passwordLabel,
                  obscureText: true,
                  focusNode: _passFocusNode,
                  showPassFocusNode: _showPasswordFocusNode,
                  styledTextController: _passController,
                  errorText: _password.error ?? validPasswordError,
                  onFieldSubmitted: (String? value) async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    await _verify();
                  },
                  onChanged: (String? value) {
                    setPassword(value ?? '');
                  },
                ),
              ),
              SizedBox(height: 16),
              CustomButton(
                  padding: EdgeInsets.only(bottom: 8),
                  text: localization.verifyLabel,
                  isLoading: isLoading,
                  type: CustomBtnType.primary,
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
