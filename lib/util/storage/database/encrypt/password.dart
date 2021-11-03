import 'dart:typed_data';

import 'package:witnet/crypto.dart' show PBKDF2;
import 'package:witnet/utils.dart' show bytesToHex;
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha512.dart';

/// Holds static methods as a module.
class Password {
  Password({required String password});

  /// Hashed the given plain-text [password] using the given [algorithm].
  static String hash(
    String password,
  ) {
    final pbkdf2 = new PBKDF2(
      blockLength: 128,
      iterationCount: 2048,
      desiredKeyLength: 64,
      digestAlgorithm: new SHA512Digest(),
    );
    String digest = bytesToHex(SHA256Digest()
        .process(pbkdf2.process(data: Uint8List(0), passphrase: password)));
    return digest;
  }

  /// Checks if the given plain-text [password] matches the given encoded [hash].
  static bool verify(String password, String hash) {
    return Password.hash(password) == hash;
  }
}
