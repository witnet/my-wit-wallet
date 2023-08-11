import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';
import 'package:witnet/witnet.dart';

// Define input validation errors
enum AddressInputError { empty, invalid, length }

Map<AddressInputError, String> errorMap = {
  AddressInputError.empty: 'This field is required',
  AddressInputError.invalid: 'Invalid address',
  AddressInputError.length: 'Address not long enough',
};

// Extend FormzInput and provide the input type and error type.
class AddressInput extends FormzInput<String, String?> {
  final bool allowValidation;
  // Call super.pure to represent an unmodified form input.
  const AddressInput.pure()
      : allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  const AddressInput.dirty({String value = '', this.allowValidation = false})
      : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String? value) {
    final validationUtils = ValidationUtils(errorMap: errorMap);
    if (this.allowValidation) {
      if (value != null) {
        if (value.isEmpty)
          return validationUtils.getErrorText(AddressInputError.empty);
        if (RegExp(r'^wit1[02-9ac-hj-np-z]{38}$').hasMatch(value)) {
          try {
            Address address = Address.fromAddress(value);
            assert(address.address.isNotEmpty);
          } catch (e) {
            return validationUtils.getErrorText(AddressInputError.invalid);
          }
        } else {
          if (value.length < 42)
            return validationUtils.getErrorText(AddressInputError.length);
          return validationUtils.getErrorText(AddressInputError.invalid);
        }
      }
    }
    return null;
  }
}
