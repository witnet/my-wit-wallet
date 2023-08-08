import 'package:formz/formz.dart';

// Define input validation errors
enum PasswordInputError { empty }

Map<PasswordInputError, String?> errorText = {
  PasswordInputError.empty: 'Please input a password'
};

String? getErrorText(PasswordInputError error) {
  return errorText[error];
}

// Extend FormzInput and provide the input type and error type.
class PasswordInput extends FormzInput<String, String?> {
  final bool allowValidation;
  // Call super.pure to represent an unmodified form input.
  const PasswordInput.pure()
      : allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  const PasswordInput.dirty({this.allowValidation = false, String value = ''})
      : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value) {
    print('allow validation ${this.allowValidation}');
    if (this.allowValidation) {
      return value.isEmpty ? getErrorText(PasswordInputError.empty) : null;
    }
    return null;
  }
}
