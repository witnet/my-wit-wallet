import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:dart_date/dart_date.dart';
import 'package:witnet_wallet/constants.dart';
import 'dart:math';

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

  String standardizeWitUnits({
    WitUnit outputUnit = WitUnit.Wit,
    WitUnit inputUnit = WitUnit.nanoWit,
    truncate = 2,
  }) {
    // from input unit to output unit
    Map<WitUnit, Map<WitUnit, int>> witUnitConversor = {
      WitUnit.Wit: {
        WitUnit.Wit: 0,
        WitUnit.milliWit: 3,
        WitUnit.microWit: 6,
        WitUnit.nanoWit: 9,
      },
      WitUnit.milliWit: {
        WitUnit.Wit: -3,
        WitUnit.milliWit: 0,
        WitUnit.microWit: 3,
        WitUnit.nanoWit: 6,
      },
      WitUnit.microWit: {
        WitUnit.Wit: -6,
        WitUnit.milliWit: -3,
        WitUnit.microWit: 0,
        WitUnit.nanoWit: 3,
      },
      WitUnit.nanoWit: {
        WitUnit.Wit: -9,
        WitUnit.milliWit: -6,
        WitUnit.microWit: -3,
        WitUnit.nanoWit: 0,
      },
    };
    try {
      if (this != 0) {
        final exponent = witUnitConversor[inputUnit]?[outputUnit] ?? 0;
        num result = this * pow(10, exponent);
        // output is nanoWit || no fixed required || result < 1
        if (outputUnit == WitUnit.nanoWit ||
            truncate == -1 ||
            result.compareTo(1) == -1) {
          // result < 1
          return Decimal.parse(result.toString()).toString();
        } else {
          return Decimal.parse(result.toStringAsFixed(truncate)).toString();
        }
      } else {
        return '0';
      }
    } catch (err) {
      print('Error standardizing Wit unit :: $err');
      return '';
    }
  }
}
