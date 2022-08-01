import 'package:formz/formz.dart';

enum WalletNameError { empty }

class WalletName extends FormzInput<String, WalletNameError> {
  const WalletName.pure() : super.pure('');
  const WalletName.dirty([String value = '']) : super.dirty(value);

  @override
  WalletNameError? validator(String? value) {
    return value?.isNotEmpty == true ? null : WalletNameError.empty;
  }
}
