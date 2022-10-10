import 'package:formz/formz.dart';

enum PasswordValidationError { empty, tooShort, notSecure }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');

  @override
  PasswordValidationError? validator(String? value) {
    return value?.isNotEmpty == true ? null : PasswordValidationError.empty;
  }
}
