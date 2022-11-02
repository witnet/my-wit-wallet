import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/create_wallet_bloc.dart';
import 'package:witnet_wallet/shared/locator.dart';

class ApiCreateWallet {
  late String walletName;
  late String? walletDescription;
  late String? password;
  late String? seedData;
  late String? seedSource;
  late WalletType walletType;

  void setSeed(String data, String source) {
    seedData = data;
    seedSource = source;
  }

  void setWalletType(WalletType type) {
    walletType = type;
  }

  void setPassword(String value) => {
    password = value
  };

  void setWalletName(String value) => walletName = value;

  void setWalletDescription(String? value) => walletDescription = value;

  void clearFormData() {
    seedData = '';
    seedSource = '';
    walletName = '';
    walletDescription = '';
    password = '';
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
