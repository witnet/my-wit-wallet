import 'package:formz/formz.dart';
import 'package:witnet/witnet.dart';

// Define input validation errors
enum AddressInputError { empty, invalid, length }

Map<AddressInputError, String?> errorText = {
  AddressInputError.empty: 'This field is required',
  AddressInputError.invalid: 'Invalid address',
  AddressInputError.length: 'Address not long enough',
};

String? getErrorText(AddressInputError error) {
  return errorText[error];
}

// Extend FormzInput and provide the input type and error type.
class AddressInput extends FormzInput<String, String?> {
  // Call super.pure to represent an unmodified form input.
  const AddressInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const AddressInput.dirty({String value = ''}) : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String? value) {
    if (value != null) {
      if (value.isEmpty) return getErrorText(AddressInputError.length);
      if (RegExp(r'^wit1[02-9ac-hj-np-z]{38}$').hasMatch(value)) {
        try {
          Address address = Address.fromAddress(value);
          assert(address.address.isNotEmpty);
        } catch (e) {
          return getErrorText(AddressInputError.invalid);
        }
      } else {
        if (value.length < 42) return getErrorText(AddressInputError.length);
        return getErrorText(AddressInputError.invalid);
      }
    }
    return null;
  }
}
