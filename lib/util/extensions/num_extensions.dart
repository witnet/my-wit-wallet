import 'package:decimal/decimal.dart';
import 'package:my_wit_wallet/constants.dart';
import 'dart:math';
import 'package:intl/intl.dart';

final formatter = NumberFormat('#,###,000');
String format(result) {
  List parts = result.toString().split('.');
  bool noCommaSeparatorNeeded = parts[0].toString().length < 3;
  String numberWithCommaSeparator =
      formatter.format(num.tryParse(parts[0] ?? 0));
  if (parts.length > 1) {
    return '${noCommaSeparatorNeeded ? parts[0] : numberWithCommaSeparator}.${parts[1]}';
  } else {
    return '${noCommaSeparatorNeeded ? parts[0] : numberWithCommaSeparator}';
  }
}

extension TruncateDoubles on double {
  double truncateToDecimals(int decimals) =>
      (this * pow(10, decimals)).truncate() / pow(10, decimals);
}

extension FormatNumber on Decimal {
  String formatWithCommaSeparator() {
    List parts = this.toString().split('.');
    bool noCommaSeparatorNeeded = parts[0].toString().length < 3;
    String numberWithCommaSeparator =
        formatter.format(num.tryParse(parts[0] ?? 0));
    if (parts.length > 1) {
      return '${noCommaSeparatorNeeded ? parts[0] : numberWithCommaSeparator}.${parts[1]}';
    } else {
      return '${noCommaSeparatorNeeded ? parts[0] : numberWithCommaSeparator}';
    }
  }
}

extension StandardizeWitUnit on num {
  Decimal standardizeWitUnits(
      {WitUnit outputUnit = WitUnit.Wit,
      WitUnit inputUnit = WitUnit.nanoWit,
      int truncate = 2}) {
    // from input unit to output unit
    Map<WitUnit, Map<WitUnit, num>> witUnitConversor = {
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
          final decimal = Decimal.parse(result.toStringAsFixed(10));
          return decimal;
        } else {
          final decimal = Decimal.parse(
              double.parse(result.toString()).truncateToDecimals(2).toString());
          return decimal;
        }
      } else {
        return Decimal.parse('0');
      }
    } catch (err) {
      print('Error standardizing Wit unit :: $err');
      return Decimal.parse('0');
    }
  }
}
