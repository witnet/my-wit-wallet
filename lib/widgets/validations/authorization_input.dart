import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum AuthorizationError { empty, invalidAuthorization }

Map<AuthorizationError, String> errorMap = {
  AuthorizationError.empty: 'This field is required',
  AuthorizationError.invalidAuthorization: 'Invalid Authorization',
};

class AuthorizationInput extends FormzInput<String, String?> {
  const AuthorizationInput.pure()
      : decriptedXprv = null,
        allowValidation = false,
        super.pure('');
  const AuthorizationInput.dirty(
      {String value = '', this.decriptedXprv, this.allowValidation = false})
      : super.dirty(value);

  final String? decriptedXprv;
  final bool allowValidation;

  @override
  String? validator(String? value) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    if (!this.allowValidation) {
      return null;
    }
    try {
      if (value != null) {
        if (value.isEmpty) {
          return validationUtils
              .getErrorText(AuthorizationError.invalidAuthorization);
        }
      }
      if (decriptedXprv != null) {
        return null;
      } else {
        return validationUtils
            .getErrorText(AuthorizationError.invalidAuthorization);
      }
    } catch (e) {
      return validationUtils
          .getErrorText(AuthorizationError.invalidAuthorization);
    }
  }
}
