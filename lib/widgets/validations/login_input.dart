import 'package:formz/formz.dart';

// Define input validation errors
enum LoginInputError { empty }

Map<LoginInputError, String?> errorText = {
  LoginInputError.empty: 'Please input a password'
};

String? getErrorText(LoginInputError error) {
  return errorText[error];
}

// Extend FormzInput and provide the input type and error type.
class LoginInput extends FormzInput<String, String?> {
  // Call super.pure to represent an unmodified form input.
  const LoginInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const LoginInput.dirty({String value = ''}) : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String? value) {
    return value != null && value.isEmpty
        ? getErrorText(LoginInputError.empty)
        : null;
  }
}
