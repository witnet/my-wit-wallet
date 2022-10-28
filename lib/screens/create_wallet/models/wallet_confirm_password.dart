import 'package:formz/formz.dart';

// ignore: todo
// TODO[#24]: Use model to validate password

enum ConfirmPasswordError { empty }

class ConfirmPassword extends FormzInput<String, ConfirmPasswordError> {
  const ConfirmPassword.pure() : super.pure('');
  const ConfirmPassword.dirty([String value = '']) : super.dirty(value);

  @override
  ConfirmPasswordError? validator(String? value) {
    return value?.isNotEmpty == true ? null : ConfirmPasswordError.empty;
  }
}
