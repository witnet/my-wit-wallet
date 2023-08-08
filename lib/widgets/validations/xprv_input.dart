import 'package:formz/formz.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';

// Define input validation errors
enum XprvError { empty, invalidXprv, invalidEncryptedXprv }

Map<XprvError, String?> errorText = {
  XprvError.empty: 'This field is required',
  XprvError.invalidXprv: 'Invalid xprv',
  XprvError.invalidEncryptedXprv: 'Invalid xprv or password',
};

String? getErrorText(XprvError error) {
  return errorText[error];
}

class XprvInput extends FormzInput<String, String?> {
  const XprvInput.pure()
      : decriptedXprv = null,
        allowValidation = false,
        xprvType = CreateWalletType.encryptedXprv,
        super.pure('');
  const XprvInput.dirty(
      {String value = '',
      required this.xprvType,
      this.decriptedXprv,
      this.allowValidation = false})
      : super.dirty(value);

  final String? decriptedXprv;
  final bool allowValidation;
  final CreateWalletType xprvType;

  @override
  String? validator(String? value) {
    if (this.allowValidation) {
      try {
        if (decriptedXprv != null) {
          return null;
        } else {
          return this.xprvType == CreateWalletType.encryptedXprv
              ? getErrorText(XprvError.invalidEncryptedXprv)
              : getErrorText(XprvError.invalidXprv);
        }
      } catch (e) {
        return this.xprvType == CreateWalletType.encryptedXprv
            ? getErrorText(XprvError.invalidEncryptedXprv)
            : getErrorText(XprvError.invalidXprv);
      }
    } else {
      return null;
    }
  }
}
