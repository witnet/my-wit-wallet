import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:sembast/sembast.dart';
import 'decoder.dart';

import 'encoder.dart';
import '../password.dart';
import "package:pointycastle/digests/sha256.dart";

Uint8List sha256({required Uint8List data}) => new SHA256Digest().process(data);
Uint8List _keyFromPassword(String password) {
  Uint8List blob = Uint8List.fromList(
      md5.convert(utf8.encode(Password.hash(password))).bytes);

  assert(blob.length == 16);
  return blob;
}

class CodecSalsa20 extends Codec<Object, String> {
  late EncoderSalsa20 _encoder;
  late DecoderSalsa20 _decoder;
  CodecSalsa20(Uint8List passwordBytes) {
    var salsa20 = Salsa20(Key(passwordBytes));
    _encoder = EncoderSalsa20(salsa20);
    _decoder = DecoderSalsa20(salsa20);
  }

  @override
  Converter<String, Object> get decoder => _decoder;

  @override
  Converter<Object, String> get encoder => _encoder;
}

/// Our plain text signature
const _encryptCodecSignature = 'Witnet';

/// Password Hash:
/// password -> PBKDF2 hash -> md5 hash
/// (md5 of the PBKDF2) of the password is used (but never stored) as a key to encrypt
/// the data using the Salsa20 algorithm with a random (8 bytes) initial value

/// usage
///
/// ```dart
/// // Initialize the encryption codec with a user password
/// var codec = getEncryptSembastCodec(password: '[your_user_password]');
/// // Open the database with the codec
/// Database db = await factory.openDatabase(dbPath, codec: codec);
///
/// // ...your database is ready to use
/// ```
SembastCodec getSembastCodecSalsa20({required String password}) {
  return SembastCodec(
      signature: _encryptCodecSignature,
      codec: CodecSalsa20(_keyFromPassword(password)));
}
