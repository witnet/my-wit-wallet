import 'package:flutter/material.dart';

class ValidationUtils {
  final Map<Enum, String>? errorMap;

  ValidationUtils({this.errorMap});

  bool isFormUnFocus(List<FocusNode> formElements) {
    return formElements.fold(true, (acc, val) => acc && !val.hasFocus);
  }

  String? getErrorText(Enum error) {
    return errorMap != null ? errorMap![error] : null;
  }
}
