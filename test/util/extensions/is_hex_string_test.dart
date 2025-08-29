import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:test/test.dart';

void main() {
  group(
      'String Extensions isHexString',
      () => {
            test(
                'should return true for valid hex strings',
                () => {
                      expect('0x1a2b3c'.isHexString(), true),
                      expect('1A2B3C'.isHexString(), true),
                      expect('abcdef'.isHexString(), true),
                      expect('1234567890'.isHexString(), true),
                    }),
            test(
                'should return false for invalid hex strings',
                () => {
                      expect('0x1z2y3c'.isHexString(), false),
                      expect('1Z2B3c'.isHexString(), false),
                      expect('hijklmn'.isHexString(), false),
                    }),
          });
}
