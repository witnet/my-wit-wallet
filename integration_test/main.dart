import "e2e_mnemonic_test.dart";
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group("End To End Mnemonic Tests", () {
    testWidgets("Create Mnemonic Test", e2eCreateMnemonicTest);
    testWidgets("Import Mnemonic Test", e2eImportMnemonicTest);
  });
}
