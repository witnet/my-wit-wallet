import 'package:my_wit_wallet/globals.dart' as globals;

class ScannedContent {
  String? get scannedContent => globals.scannedContent;

  void setScannedContent(String value) {
    globals.scannedContent = value;
  }

  void clearScannedContent() {
    globals.scannedContent = null;
  }
}
