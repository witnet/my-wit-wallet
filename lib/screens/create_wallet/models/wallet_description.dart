import 'package:formz/formz.dart';

enum WalletDescriptionError { empty }

class WalletDescription extends FormzInput<String, WalletDescriptionError> {
  const WalletDescription.pure() : super.pure('');
  const WalletDescription.dirty([String value = '']) : super.dirty(value);

  @override
  WalletDescriptionError? validator(String? value) {
    return value?.isNotEmpty == true ? null : WalletDescriptionError.empty;
  }
}
