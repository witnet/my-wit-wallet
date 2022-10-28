import 'package:formz/formz.dart';

// ignore: todo
// TODO[#24]: Use model to validate password

enum PasswordError { empty }

class Password extends FormzInput<String, PasswordError> {
  const Password.pure() : super.pure('');
  const Password.dirty([String value = '']) : super.dirty(value);

  @override
  PasswordError? validator(String? value) {
    return value?.isNotEmpty == true ? null : PasswordError.empty;
  }
}
