import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum PasswordInputError { empty }

Map<PasswordInputError, String> errorMap = {
  PasswordInputError.empty: 'Please input a password'
};

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
    if (this.allowValidation) {
      return value.isEmpty
          ? ValidationUtils(errorMap: errorMap)
              .getErrorText(PasswordInputError.empty)
          : null;
    }
    return null;
  }
}
