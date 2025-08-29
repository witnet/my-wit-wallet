import 'package:formz/formz.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum MetadataInputError { invalidHex, invalidLength }

Map<MetadataInputError, String> errorMap = {
  MetadataInputError.invalidHex: 'Invalid hex metadata',
  MetadataInputError.invalidLength: 'Invalid length metadata',
};

// Extend FormzInput and provide the input type and error type.
class MetadataInput extends FormzInput<String, String?> {
  final bool allowValidation;
  // Call super.pure to represent an unmodified form input.
  const MetadataInput.pure()
      : allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  const MetadataInput.dirty({String value = '', this.allowValidation = false})
      : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String? value) {
    final _validationUtils = ValidationUtils(errorMap: errorMap);

    if (!this.allowValidation) {
      return null;
    }

    if (value != null) {
      if (!value.isHexString()) {
        return _validationUtils.getErrorText(MetadataInputError.invalidHex);
      }

      if (!((value.startsWith("0x") && (value.substring(2).length == 20 * 2)) ||
          (value.length == 20 * 2))) {
        return _validationUtils.getErrorText(MetadataInputError.invalidLength);
      }
    }
    return null;
  }
}
