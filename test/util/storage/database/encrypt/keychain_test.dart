import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:test/test.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/keychain.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  Locator.setup();
  String sheikahXprv = dotenv.get('SHEIKAH_XPRV');
  test('Password Encryption Test', () async {
    KeyChain keyChain = KeyChain();
    final String password = 'Witnet';
    final String incorrectPassword = 'Witnet1';

    var encoded = await keyChain.encode(password);

    var decoded = await keyChain.decode(sheikahXprv, encoded, password);
    var decodedIncorrect =
        await keyChain.decode(sheikahXprv, encoded, incorrectPassword);
    expect(decoded,
        'a70cf2d30f83959261e6180437d3e21f6e4c1572894274a89de2d94a598201a1');
    expect(decoded == decodedIncorrect, false);
  });
}
