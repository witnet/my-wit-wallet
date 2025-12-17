import 'dart:convert';

import 'package:witnet/schema.dart';

String? metadataFromOutputs(
  List<ValueTransferOutput> outputs, {
  List<String> trueOutputAddresses = const [],
  List<String> changeOutputAddresses = const [],
}) {
  if (outputs.isEmpty) {
    return null;
  }

  Iterable<ValueTransferOutput> candidates =
      outputs.where((output) => output.value.toInt() == 1);

  if (trueOutputAddresses.isNotEmpty || changeOutputAddresses.isNotEmpty) {
    final excluded = <String>{
      ...trueOutputAddresses,
      ...changeOutputAddresses,
    };
    final filtered = candidates
        .where((output) => !excluded.contains(output.pkh.address))
        .toList();
    if (filtered.isNotEmpty) {
      candidates = filtered;
    }
  }

  if (candidates.isEmpty) {
    return null;
  }

  return _decodeMetadataOutput(candidates.first);
}

String? _decodeMetadataOutput(ValueTransferOutput output) {
  final bytes = List<int>.from(output.pkh.hash);
  int end = bytes.length;
  while (end > 0 && bytes[end - 1] == 0) {
    end--;
  }
  if (end == 0) {
    return null;
  }

  final trimmed = bytes.sublist(0, end);
  String decoded;
  try {
    decoded = utf8.decode(trimmed, allowMalformed: true);
  } catch (_) {
    return '0x${output.pkh.hex}';
  }

  if (_isPrintable(decoded)) {
    return decoded;
  }

  return '0x${output.pkh.hex}';
}

bool _isPrintable(String value) {
  if (value.contains('\uFFFD')) {
    return false;
  }
  for (final rune in value.runes) {
    if (rune == 0x09 || rune == 0x0A || rune == 0x0D) {
      continue;
    }
    if (rune < 0x20 || rune == 0x7F) {
      return false;
    }
  }
  return true;
}
