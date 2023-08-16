import 'package:formz/formz.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum XprvError { empty, invalidXprv, invalidEncryptedXprv }

Map<XprvError, String> errorMap = {
  XprvError.empty: 'This field is required',
  XprvError.invalidXprv: 'Invalid xprv',
  XprvError.invalidEncryptedXprv: 'Invalid xprv or password',
};

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
    final validationUtils = ValidationUtils(errorMap: errorMap);
    if (!this.allowValidation) {
      return null;
    }
    try {
      if (decriptedXprv != null) {
        return null;
      } else {
        return this.xprvType == CreateWalletType.encryptedXprv
            ? validationUtils.getErrorText(XprvError.invalidEncryptedXprv)
            : validationUtils.getErrorText(XprvError.invalidXprv);
      }
    } catch (e) {
      return this.xprvType == CreateWalletType.encryptedXprv
          ? validationUtils.getErrorText(XprvError.invalidEncryptedXprv)
          : validationUtils.getErrorText(XprvError.invalidXprv);
    }
  }
}
