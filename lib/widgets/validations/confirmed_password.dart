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
        allowValidation = false,
        super.pure('');
  const ConfirmedPassword.dirty(
      {required this.original, String value = '', this.allowValidation = false})
      : super.dirty(value);

  final PasswordInput original;
  final bool allowValidation;

  @override
  String? validator(String? value) {
    if (this.allowValidation) {
      if (value != null) {
        if (value != this.original.value)
          return getErrorText(ConfirmedPasswordError.match);
        if (value.isEmpty) return getErrorText(ConfirmedPasswordError.empty);
      }
    }

    return null;
  }
}
