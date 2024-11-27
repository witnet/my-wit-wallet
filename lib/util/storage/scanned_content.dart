import 'package:my_wit_wallet/globals.dart' as globals;

enum ScannedType {
  address,
  authorization,
  xprv,
}

class ScannedContent {
  String? get scannedAddress => globals.scannedAddress;
  String? get scannedAuthorization => globals.scannedAuthorization;
  String? get scannedXprv => globals.scannedXprv;

  void setScannedContent({required String value, required type}) {
    if (type == ScannedType.address) globals.scannedAddress = value;
    if (type == ScannedType.authorization) globals.scannedAuthorization = value;
    if (type == ScannedType.xprv) globals.scannedXprv = value;
  }

  void clearScannedContent({required ScannedType type}) {
    if (type == ScannedType.address) globals.scannedAddress = null;
    if (type == ScannedType.authorization) globals.scannedAuthorization = null;
    if (type == ScannedType.xprv) globals.scannedXprv = null;
  }
}
