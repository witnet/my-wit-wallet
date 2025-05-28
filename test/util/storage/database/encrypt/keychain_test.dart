import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:test/test.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/keychain.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/password.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  Locator.setup();
  test('Password Encryption Test', () async {
    KeyChain keyChain = KeyChain();
    final String password = 'password';
    final String incorrectPassword = 'Witnet1';

    /// verify when encoding the same key we get a unique value each time
    final String encoded01 = await keyChain.encode(password);
    final String encoded02 = await keyChain.encode(password);
    expect(encoded01 != encoded02, true);

    /// verify decoding to the same hash
    var decoded01 = await keyChain.decode(encoded01, password);
    var decoded02 = await keyChain.decode(encoded02, password);
    var nDecode = await keyChain.decode(encoded01, incorrectPassword);
    expect(Password.verify(password, decoded01!), true);
    expect(Password.verify(password, decoded02!), true);

    /// verify when decoding an incorrect password it is rejected
    expect(Password.verify(password, nDecode!), false);
  });
}
