import 'package:formz/formz.dart';
import 'package:my_wit_wallet/widgets/validations/validation_utils.dart';

// Define input validation errors
enum MessageInputError { empty }

Map<MessageInputError, String> errorMap = {
  MessageInputError.empty: 'Please enter a message to sign'
};

// Extend FormzInput and provide the input type and error type.
class MessageInput extends FormzInput<String, String?> {
  final bool allowValidation;
  // Call super.pure to represent an unmodified form input.
  const MessageInput.pure()
      : allowValidation = false,
        super.pure('');

  // Call super.dirty to represent a modified form input.
  const MessageInput.dirty({this.allowValidation = false, String value = ''})
      : super.dirty(value);

  // Override validator to handle validating a given input value.
  @override
  String? validator(String value) {
    if (!this.allowValidation) {
      return null;
    }
    return value.isEmpty
        ? ValidationUtils(errorMap: errorMap)
            .getErrorText(MessageInputError.empty)
        : null;
  }
}
