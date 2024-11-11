import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/input_password.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:my_wit_wallet/widgets/styled_text_controller.dart';


typedef void ValidateCallback(
    {required bool validate, required String password});
typedef void PasswordCallback({required String password});
typedef void ClearErrorCallback();

class PasswordValidation extends StatefulWidget {
  final ValidateCallback validate;
  final PasswordCallback passwordUpdates;
  final ClearErrorCallback clearError;
  final String? passwordInputErrorText;
  PasswordValidation(
      {Key? key,
      required this.validate,
      required this.passwordUpdates,
      required this.clearError,
      this.passwordInputErrorText})
      : super(key: key);
  @override
  PasswordValidationState createState() => PasswordValidationState();
}

class PasswordValidationState extends State<PasswordValidation>
    with TickerProviderStateMixin {
  PasswordInput _password = PasswordInput.pure();
  bool isLoading = false;

  final _loginController = StyledTextController();
  final _loginFocusNode = FocusNode();
  final _showPasswordFocusNode = FocusNode();
  ValidationUtils validationUtils = ValidationUtils();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _loginFocusNode.dispose();
    super.dispose();
  }

  bool formValidation() {
    return _password.isValid;
  }

  bool validateForm({force = false}) {
    if (force) {
      setPassword(_password.value, validate: true);
    }
    return formValidation();
  }

  void setPassword(String password, {bool? validate}) {
    setState(() {
      widget.passwordUpdates(password: password);
      _password = PasswordInput.dirty(
          value: password,
          allowValidation:
              validate ?? validationUtils.isFormUnFocus([_loginFocusNode]));
    });
  }

  Form _loginForm() {
    _loginFocusNode.addListener(() => validateForm());
    return Form(
      autovalidateMode: AutovalidateMode.disabled,
      child: InputPassword(
        hint: 'Password',
        errorText: _password.error ?? widget.passwordInputErrorText,
        showPassFocusNode: _showPasswordFocusNode,
        obscureText: true,
        styledTextController: _loginController,
        focusNode: _loginFocusNode,
        onChanged: (String? value) {
          if (mounted) {
            widget.clearError();
            setPassword(value ?? '');
          }
        },
        onFieldSubmitted: (String? value) {
          // hide keyboard
          FocusManager.instance.primaryFocus?.unfocus();
          widget.validate(
              validate: validateForm(force: true), password: _password.value);
        },
        onTap: () {
          _loginFocusNode.requestFocus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loginForm();
  }
}
