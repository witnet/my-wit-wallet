import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/widgets/validations/password_input.dart';

import '../../../util/storage/database/wallet.dart';

class ApiCreateWallet {
  String walletName = "";
  String? password;
  late String? seedData;
  late String? seedSource;
  late CreateWalletType createWalletType;
  late WalletType walletType = WalletType.hd;

  void setSeed(String data, String source) {
    seedData = data;
    seedSource = source;
  }

  void setCreateWalletType(CreateWalletType type) {
    createWalletType = type;
  }

  void setPassword(String value) => password = value;

  void setWalletName(String value) => walletName = value;

  void setWalletType(WalletType value) => walletType = value;

  void clearFormData() {
    seedData = '';
    seedSource = '';
    walletName = '';
    password = null;
    walletType = WalletType.unknown;
  }

  Future<String> createMnemonic(
      {required int wordCount, String language = 'English'}) async {
    return await Locator.instance
        .get<ApiCrypto>()
        .generateMnemonic(wordCount, language);
  }

  Future<String?>? decryptedXprv(String xprvString, CreateWalletType _xprvType,
      PasswordInput? password) async {
    ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
    try {
      int xprvLength = xprvString.length;
      String? xprvDecripted;
      if (xprvLength == ENCRYPTED_XPRV_LENGTH &&
          _xprvType == CreateWalletType.encryptedXprv) {
        xprvDecripted = await apiCrypto.decryptXprv(
            xprv: xprvString, password: password?.value ?? '');
      } else if (xprvLength == XPRV_LENGTH &&
          _xprvType == CreateWalletType.xprv) {
        xprvDecripted = await apiCrypto.verifiedXprv(xprv: xprvString);
      }
      if (xprvDecripted != null) {
        return xprvDecripted;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void printDebug() {
    print('Current Data:');
    print(' name: $walletName');
    print(' source: $seedSource');
    print(' seed: $seedData');
    print(' password: $password');
  }
}
