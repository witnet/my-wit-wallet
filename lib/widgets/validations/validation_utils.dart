class ValidationUtils {
  final Map<Enum, String> errorMap;

  ValidationUtils({required this.errorMap});

  String? getErrorText(Enum error) {
    return errorMap[error];
  }
}
