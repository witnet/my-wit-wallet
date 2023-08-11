import 'package:formz/formz.dart';

// Define input validation errors
enum PasswordInputError { empty, invalid }

Map<PasswordInputError, String?> errorText = {
  PasswordInputError.empty: 'Please input a password',
  PasswordInputError.invalid: 'Invalid password'
};

String? getErrorText(PasswordInputError error) {
  return errorText[error];
}

// Extend FormzInput and provide the input type and error type.
class VerifyPasswordInput extends FormzInput<String, String?> {
  final bool allowValidation;
  final String? decriptedXprv;
  // Call super.pure to represent an unmodified form input.
  const VerifyPasswordInput.pure()
      : allowValidation = false,
        decriptedXprv = null,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  const VerifyPasswordInput.dirty(
      {this.allowValidation = false, this.decriptedXprv, String value = ''})
      : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value) {
    if (this.allowValidation) {
      if (value.isEmpty) {
        return getErrorText(PasswordInputError.empty);
      } else if (this.decriptedXprv == null) {
        return getErrorText(PasswordInputError.invalid);
      }
    }
    return null;
  }
}
