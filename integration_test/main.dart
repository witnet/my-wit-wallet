import 'package:flutter_test/flutter_test.dart';

import 'package:my_wit_wallet/globals.dart' as globals;
import 'test_utils.dart';

void main() async {
  globals.testingActive = true;

  group("End To End Mnemonic Tests", () {
    testWidgets("Create Mnemonic Test", e2eCreateMnemonicTest);
    testWidgets("Import Mnemonic Test", e2eImportMnemonicTest);
    testWidgets("Import Xprv Test", e2eImportXprvTest);
    testWidgets("Export Node Xprv Test", e2eExportXprvTest);
    testWidgets("Export Hd Xprv Test", e2eExportHdXprvTest);
    testWidgets("Sign message Test", e2eSignMessageTest);
    testWidgets('Update current wallet', e2eUpdateCurrentWalletTest);
    testWidgets("Auth preferences Test", e2eAuthPreferencesTest);
    testWidgets("Show node stats Test", e2eShowNodeStatsTest);
    testWidgets("Re-establish wallets", e2eReEstablishWallets);
    testWidgets("Import Xprv From Sheikah Test", e2eImportXprvFromSheikahTest);
    testWidgets("Update theme color", e2eUpdateThemeColorTest);

  });
}