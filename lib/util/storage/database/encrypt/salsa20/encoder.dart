import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart';

Random _random = Random.secure();

Uint8List _randomBytes(int length) {
  return Uint8List.fromList(
      List<int>.generate(length, (index) => _random.nextInt(256)));
}

class EncoderSalsa20 extends Converter<Object, String> {
  Salsa20 salsa20;
  EncoderSalsa20(this.salsa20);
  @override
  String convert(dynamic input) {
    Uint8List iv = _randomBytes(8);
    String ivEncoded = base64.encode(iv);
    assert(ivEncoded.length == 12);
    String encoded =
        Encrypter(salsa20).encrypt(json.encode(input), iv: IV(iv)).base64;
    return '$ivEncoded$encoded';
  }
}
