import 'package:witnet/data_structures.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/witnet.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/utxo_list_to_string.dart';
import 'crypto_bloc.dart';

enum SeedSource { mnemonic, xprv, encryptedXprv }

// used to call the isolate thread from anywhere in the main app
class ApiCrypto {
  ApiCrypto();

  late String? walletName;
  late String? seed;
  late String? seedSource;
  late String? password;
  late WalletType? walletType;
  ApiDatabase db = Locator.instance<ApiDatabase>();

  void setInitialWalletData(String walletName, String seed, String seedSource,
      String password, WalletType walletType) {
    this.walletName = walletName;
    this.seed = seed;
    this.seedSource = seedSource;
    this.password = password;
    this.walletType = walletType;
  }

  void clearInitialWalletData() {
    this.walletName = null;
    this.seed = null;
    this.seedSource = null;
  }

  Future<String> generateMnemonic(int wordCount, String language) async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
      return await cryptoIsolate.send(method: 'generateMnemonic', params: {
        'wordCount': wordCount,
        'language': language,
      });
    } catch (e) {
      print('Error in generate Mnemonic $e');
      rethrow;
    }
  }

  Future<Account> generateAccount(
      Wallet wallet, KeyType keyType, int index) async {
    try {
      if (keyType == KeyType.master) {
        return wallet.masterAccount!;
      }
      CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
      Xpub xpub = await cryptoIsolate.send(method: 'generateKey', params: {
        'keyType': keyType.name,
        'external_keychain': wallet.externalXpub,
        'internal_keychain': wallet.internalXpub,
        'index': index
      });
      Account _account = Account(
          walletName: wallet.name, address: xpub.address, path: xpub.path!);
      _account.walletId = wallet.id;
      return _account;
    } catch (e) {
      rethrow;
    }
  }

  Future<Wallet> initializeWallet() async {
    try {
      CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
      Wallet wallet =
          await cryptoIsolate.send(method: 'initializeWallet', params: {
        'walletName': walletName,
        'walletType': walletType != null ? walletType!.name : null,
        'seedSource': seedSource,
        'seed': seed,
        'password': password,
      });
      clearInitialWalletData();
      return wallet;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<KeyedSignature>> signTransaction(
    List<Utxo> utxos,
    Wallet walletStorage,
    String transactionId,
  ) async {
    Map<String, List<String>> _signers = {};
    // get master key
    String key = await db.getKeychain();

    /// loop through utxos
    for (int i = 0; i < utxos.length; i++) {
      Utxo currentUtxo = utxos.elementAt(i);

      Wallet currentWallet = walletStorage;
      if (currentWallet.walletType == WalletType.hd) {
        /// loop though every external account
        currentWallet.externalAccounts.forEach((index, account) {
          if (rawJsonUtxosList(account.utxos)
              .contains(currentUtxo.toRawJson())) {
            if (_signers.containsKey(currentWallet.xprv)) {
              _signers[currentWallet.xprv]!.add(account.path);
            } else {
              _signers[currentWallet.xprv!] = [account.path];
            }
          }
        });

        /// loop though every internal account
        currentWallet.internalAccounts.forEach((index, account) {
          if (rawJsonUtxosList(account.utxos)
              .contains(currentUtxo.toRawJson())) {
            if (_signers.containsKey(currentWallet.xprv)) {
              _signers[currentWallet.xprv]!.add(account.path);
            } else {
              _signers[currentWallet.xprv!] = [account.path];
            }
          }
        });
      } else {
        /// single account
        if (_signers.containsKey(currentWallet.xprv)) {
          _signers[currentWallet.xprv]!.add(currentWallet.masterAccount!.path);
        } else {
          _signers[currentWallet.xprv!] = [currentWallet.masterAccount!.path];
        }
      }
    }
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    List<KeyedSignature> signatures = await cryptoIsolate.send(
        method: 'signTransaction',
        params: {
          'password': key,
          'signers': _signers,
          'transaction_id': transactionId
        });
    return signatures;
  }

  Future<String> hashPassword({required String password}) async {
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    return await cryptoIsolate.send(method: 'hashPassword', params: {
      'password': password,
    });
  }

  Future<String> encryptXprv(
      {required String xprv, required String password}) async {
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    return await cryptoIsolate.send(method: 'encryptXprv', params: {
      'xprv': xprv,
      'password': password,
    });
  }

  Future<String> verifiedXprv({required String xprv}) async {
    try {
      Xprv _xprv = Xprv.fromXprv(xprv);
      assert(_xprv.address.address.isNotEmpty);
    } catch (e) {
      print('error $e');
      rethrow;
    }
    return xprv;
  }

  Future<String> decryptXprv(
      {required String xprv, required String password}) async {
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    final response = await cryptoIsolate.send(method: 'decryptXprv', params: {
      'xprv': xprv,
      'password': password,
    }) as Map<String, String>;

    if (response.containsKey('xprv')) {
      return response['xprv']!;
    } else {
      return response['error']!;
    }
  }

  Future<bool> verifySheikahXprv(
      {required String xprv, required String password}) async {
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    return await cryptoIsolate.send(method: 'decryptXprv', params: {
      'xprv': xprv,
      'password': password,
    });
  }

  Future<bool> verifyLocalXprv(
      {required String xprv, required String password}) async {
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    return await cryptoIsolate.send(method: 'decryptXprv', params: {
      'xprv': xprv,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> signMessage(
      String message, String address) async {
    String key = await db.getKeychain();

    Wallet currentWallet = db.walletStorage.currentWallet;
    Account? _account = currentWallet.allAccounts()[address];

    // the signer map is {master xprv: address path}
    // e.g. {"xprv1...": "m/3h/4919h/0h/0/0"}
    Map<String, String> _signer = {
      currentWallet.xprv!: _account!.path,
    };

    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    return await cryptoIsolate.send(method: 'signMessage', params: {
      'password': key,
      'signer': _signer,
      'message': message,
    });
  }
}
