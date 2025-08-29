extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }

  String cropMiddle(int length) {
    if (this.length > length) {
      var leftSizeLength = ((length - 3) / 2).floor();
      var rightSizeLength = this.length - leftSizeLength;
      return '${this.substring(0, leftSizeLength)}…${this.substring(rightSizeLength)}';
    } else {
      return '';
    }
  }

  String cropAddress(int length) {
    var leftSizeLength = 4;
    var rightSizeLength = (length < 6) ? this.length - 6 : this.length - length;
    return '${this.substring(0, leftSizeLength)}…${this.substring(rightSizeLength)}';
  }

  String fromPascalCaseToTitle() {
    final result = this.split(RegExp('(?=[A-Z])'));
    return result.join(' ').toLowerCase().capitalize();
  }

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.capitalize())
      .join(' ');

  bool toBoolean() => this == 'true' || this == 'True';

  bool isHexString() {
    final hexRegex = RegExp(r'^[a-fA-F0-9]+$');

    if (this.startsWith("0x")) {
      return hexRegex.hasMatch(this.substring(2));
    } else {
      return hexRegex.hasMatch(this);
    }
  }
}
