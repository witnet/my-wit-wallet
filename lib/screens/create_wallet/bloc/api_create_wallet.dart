import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:my_wit_wallet/shared/locator.dart';

import '../../../util/storage/database/wallet.dart';

class ApiCreateWallet {
  String walletName = "";
  String walletDescription = "";
  String? password;
  late String? seedData;
  late String? seedSource;
  late CreateWalletType createWalletType;
  late WalletType? walletType;

  void setSeed(String data, String source) {
    seedData = data;
    seedSource = source;
  }

  void setWalletType(CreateWalletType type) {
    createWalletType = type;
  }

  void setPassword(String value) => password = value;

  void setWalletName(String value) => walletName = value;

  void setWalletDescription(String value) => walletDescription = value;

  void clearFormData() {
    seedData = '';
    seedSource = '';
    walletName = '';
    walletDescription = '';
    password = null;
  }

  Future<String> createMnemonic(
      {required int wordCount, String language = 'English'}) async {
    return await Locator.instance
        .get<ApiCrypto>()
        .generateMnemonic(wordCount, language);
  }

  void printDebug() {
    print('Current Data:');
    print(' name: $walletName');
    print(' description: $walletDescription');
    print(' source: $seedSource');
    print(' seed: $seedData');
    print(' password: $password');
  }
}
