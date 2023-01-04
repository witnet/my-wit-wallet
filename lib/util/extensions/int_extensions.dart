import 'package:intl/intl.dart';
import 'package:dart_date/dart_date.dart';

extension TimestampExtension on int {
  String formatDuration() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(this * 1000);
    return date
        .subMilliseconds(DateTime.now().getMicroseconds)
        .timeago(locale: 'en');
  }

  String formatDate() {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(this * 1000);
    final formatedDate = new DateFormat('yyyy-MM-dd hh:mm:ss');
    return formatedDate.format(date);
  }
}
