import 'package:flutter/widgets.dart';
import 'package:my_wit_wallet/widgets/validations/metadata_input.dart';
import 'package:test/test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  test('Validation disabled should always return null', () async {
    const String metadata = 'notAHexString';
    final MetadataInput input =
        MetadataInput.dirty(value: metadata, allowValidation: false);

    expect(input.validator(metadata), null);
  });

  test('Non-hex string returns invalidHex error', () async {
    const String metadata = 'ZXY123'; // not a valid hex
    final MetadataInput input =
        MetadataInput.dirty(value: metadata, allowValidation: true);

    expect(input.validator(metadata), errorMap[MetadataInputError.invalidHex]);
  });

  test('Valid hex but invalid length returns invalidLength error', () async {
    const String metadata = '0x1234abcd'; // valid hex but only 8 chars after 0x
    final MetadataInput input =
        MetadataInput.dirty(value: metadata, allowValidation: true);

    expect(
        input.validator(metadata), errorMap[MetadataInputError.invalidLength]);
  });

  test('Valid 40-char hex string passes validation', () async {
    const String metadata =
        'aabbccddeeff00112233445566778899aabbccdd'; // 40 hex chars
    final MetadataInput input =
        MetadataInput.dirty(value: metadata, allowValidation: true);

    expect(input.validator(metadata), null);
  });

  test('Valid 42-char hex string with 0x passes validation', () async {
    const String metadata =
        '0x' + 'aabbccddeeff00112233445566778899aabbccdd'; // 0x + 40 hex
    final MetadataInput input =
        MetadataInput.dirty(value: metadata, allowValidation: true);

    expect(input.validator(metadata), null);
  });
}
