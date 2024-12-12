import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:witnet/schema.dart';

// Define input validation errors
enum AuthorizationError {
  empty,
  invalidAuthorization,
  decodingError,
  emptyWithdrawer
}

Map<AuthorizationError, String> errorMap = {
  AuthorizationError.empty: 'This field is required',
  AuthorizationError.invalidAuthorization: 'Invalid Authorization',
  AuthorizationError.decodingError: 'Error decoding authorization',
  AuthorizationError.emptyWithdrawer:
      'Invalid Authorization, withdrawer input is empty'
};

class AuthorizationInput extends FormzInput<String, String?> {
  const AuthorizationInput.pure()
      : withdrawerAddress = null,
        allowValidation = false,
        super.pure('');
  const AuthorizationInput.dirty(
      {String value = '', this.withdrawerAddress, this.allowValidation = false})
      : super.dirty(value);

  final String? withdrawerAddress;
  final bool allowValidation;

  @override
  String? validator(String? value) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    if (!this.allowValidation) {
      return null;
    }
    try {
      if (withdrawerAddress == null) {
        return validationUtils.getErrorText(AuthorizationError.emptyWithdrawer);
      }
      if (value != null) {
        if (value.isEmpty) {
          return validationUtils.getErrorText(AuthorizationError.empty);
        }
        try {
          KeyedSignature.fromAuthorization(
              authorization: value, withdrawer: withdrawerAddress!);
          return null;
        } catch (err) {
          print('Error decoding authorization $err');
          return validationUtils
              .getErrorText(AuthorizationError.invalidAuthorization);
        }
      } else {
        return validationUtils.getErrorText(AuthorizationError.empty);
      }
    } catch (e) {
      return validationUtils
          .getErrorText(AuthorizationError.invalidAuthorization);
    }
  }
}
