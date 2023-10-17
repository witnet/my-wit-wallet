import 'e2e_auth_preferences_test.dart';
import 'e2e_import_mnemonic_test.dart';
import 'e2e_show_node_stats.dart';
import "e2e_mnemonic_test.dart";
import 'package:flutter_test/flutter_test.dart';
import 'e2e_re_establish_wallet.dart';
import "e2e_import_xprv_test.dart";
import "e2e_export_xprv_test.dart";
import 'e2e_import_xprv_from_sheikah_test.dart';
import 'e2e_sign_message_test.dart';
import 'e2e_update_wallet_test.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

void main() async {
  globals.testingActive = true;

  group("End To End Mnemonic Tests", () {
    testWidgets("Create Mnemonic Test", e2eCreateMnemonicTest);
    testWidgets("Import Mnemonic Test", e2eImportMnemonicTest);
    testWidgets("Import Xprv Test", e2eImportXprvTest);
    testWidgets("Export Xprv Test", e2eExportXprvTest);
    testWidgets("Export Xprv Test", e2eSignMessageTest);
    testWidgets('Update current wallet', e2eUpdateCurrentWalletTest);
    testWidgets("Auth preferences Test", e2eAuthPreferencesTest);
    testWidgets("Show node stats Test", e2eShowNodeStatsTest);
    testWidgets("Re-establish wallets", e2eReEstablishWallets);
    testWidgets("Import Xprv From Sheikah Test", e2eImportXprvFromSheikahTest);
  });
}
