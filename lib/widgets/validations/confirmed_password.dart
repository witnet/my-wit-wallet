import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';

// Define input validation errors
enum ConfirmedPasswordError { empty, match }

Map<ConfirmedPasswordError, String?> errorText = {
  ConfirmedPasswordError.empty: 'Please input a password',
  ConfirmedPasswordError.match: 'Password mismatch'
};

String? getErrorText(ConfirmedPasswordError error) {
  return errorText[error];
}

class ConfirmedPassword extends FormzInput<String, String?> {
  const ConfirmedPassword.pure()
      : original = const PasswordInput.pure(),
        super.pure('');
  const ConfirmedPassword.dirty({required this.original, String value = ''})
      : super.dirty(value);

  final PasswordInput original;

  @override
  String? validator(String? value) {
    if (value != null) {
      if (value != this.original.value)
        return getErrorText(ConfirmedPasswordError.match);
      if (value.isEmpty) return getErrorText(ConfirmedPasswordError.empty);
    }

    return null;
  }
}
