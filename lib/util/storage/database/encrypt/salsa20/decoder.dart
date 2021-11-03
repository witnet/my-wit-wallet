import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class DecoderSalsa20 extends Converter<String, Object> {
  Salsa20 salsa20;
  DecoderSalsa20(this.salsa20);
  @override
  Object convert(String input) {
    // read the initial value that was prepended
    assert(input.length >= 12);
    Uint8List iv = base64.decode(input.substring(0, 12));
    // extract the real input
    input = input.substring(12);
    // decode the input
    var decoded = json.decode(Encrypter(salsa20).decrypt64(input, iv: IV(iv)));

    if (decoded is Map) {
      return decoded.cast<String, Object>();
    }
    return decoded;
  }
}
