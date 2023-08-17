import 'e2e_import_mnemonic_test.dart';
import "e2e_mnemonic_test.dart";
import 'package:flutter_test/flutter_test.dart';
import 'e2e_re_establish_wallet.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

void main() async {
  globals.testingActive = true;

  group("End To End Mnemonic Tests", () {
    testWidgets("Create Mnemonic Test", e2eCreateMnemonicTest);
    testWidgets("Import Mnemonic Test", e2eImportMnemonicTest);
    testWidgets("Re-establish wallets", e2eReEstablishWallets);
  });
}
