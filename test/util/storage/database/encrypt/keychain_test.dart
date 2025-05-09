import 'package:test/test.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/keychain.dart';

void main() async {
  test('Password Encryption Test', () async {
    KeyChain keyChain = KeyChain();
    final String password = 'Witnet';
    final String incorrectPassword = 'Witnet1';

    var encoded = await keyChain.encode(password);

    expect(await keyChain.validatePassword(encoded, password), true);
    expect(await keyChain.validatePassword(encoded, incorrectPassword), false);
    expect(keyChain.decode(encoded, password).runtimeType, String);
    expect(keyChain.decode(encoded, incorrectPassword).runtimeType, Null);
  });
}
