import 'dart:isolate';
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
  late String? walletName;
  late String? seed;
  late String? seedSource;
  late String? password;
  late WalletType? walletType;

  ApiCrypto();

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
      var receivePort = ReceivePort();
      cryptoIsolate.send(
          method: 'generateMnemonic',
          params: {
            'wordCount': wordCount,
            'language': language,
          },
          port: receivePort.sendPort);
      return await receivePort.first.then((value) {
        return value;
      });
    } catch (e) {
      print('Error $e');
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
      final receivePort = ReceivePort();
      cryptoIsolate.send(
        method: 'generateKey',
        params: {
          'keyType': keyType.name,
          'external_keychain': wallet.externalXpub,
          'internal_keychain': wallet.internalXpub,
          'index': index
        },
        port: receivePort.sendPort,
      );
      Xpub xpub = await receivePort.first.then((value) {
        var val = value as Map<String, dynamic>;
        var _xpub = val['xpub'];
        return _xpub;
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

      final receivePort = ReceivePort();

      cryptoIsolate.send(
          method: 'initializeWallet',
          params: {
            'walletName': walletName,
            'walletType': walletType != null ? walletType!.name : null,
            'seedSource': seedSource,
            'seed': seed,
            'password': password,
          },
          port: receivePort.sendPort);
      clearInitialWalletData();
      Wallet dbWallet = await receivePort.first.then((value) {
        var val = value as Map<String, dynamic>;
        var _wallet = val['wallet'];
        return _wallet;
      });

      return dbWallet;
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
    ApiDatabase db = Locator.instance<ApiDatabase>();
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
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'signTransaction',
        params: {
          'password': key,
          'signers': _signers,
          'transaction_id': transactionId
        },
        port: receivePort.sendPort);

    List<KeyedSignature> signatures = await receivePort.first.then((value) {
      return value as List<KeyedSignature>;
    });
    return signatures;
  }

  Future<String> hashPassword({required String password}) async {
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'hashPassword',
        params: {
          'password': password,
        },
        port: receivePort.sendPort);
    Map<String, String> response =
        await receivePort.first.then((value) => value as Map<String, String>);
    return response['hash']!;
  }

  Future<String> encryptXprv(
      {required String xprv, required String password}) async {
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'encryptXprv',
        params: {
          'xprv': xprv,
          'password': password,
        },
        port: receivePort.sendPort);
    Map<String, String> passwordHash =
        await receivePort.first.then((value) => value as Map<String, String>);
    return passwordHash['xprv']!;
  }

  Future<String> verifiedXprv({required String xprv}) async {
    try {
      Xprv _xprv = Xprv.fromXprv(xprv);
      assert(_xprv.address.address.isNotEmpty);
    } catch (e) {
      print('error $e');
      print('invalid xprv');
      rethrow;
    }
    return xprv;
  }

  Future<String> decryptXprv(
      {required String xprv, required String password}) async {
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'decryptXprv',
        params: {
          'xprv': xprv,
          'password': password,
        },
        port: receivePort.sendPort);

    Map<String, String> response =
        await receivePort.first.then((value) => value as Map<String, String>);
    print('response XRPV $response');
    if (response.containsKey('xprv')) {
      return response['xprv']!;
    } else {
      return response['error']!;
    }
  }

  Future<bool> verifySheikahXprv(
      {required String xprv, required String password}) async {
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'decryptXprv',
        params: {
          'xprv': xprv,
          'password': password,
        },
        port: receivePort.sendPort);
    bool valid = await receivePort.first.then((value) => value as bool);
    return valid;
  }

  Future<bool> verifyLocalXprv(
      {required String xprv, required String password}) async {
    final receivePort = ReceivePort();
    CryptoIsolate cryptoIsolate = Locator.instance.get<CryptoIsolate>();
    cryptoIsolate.send(
        method: 'decryptXprv',
        params: {
          'xprv': xprv,
          'password': password,
        },
        port: receivePort.sendPort);
    bool valid = await receivePort.first.then((value) => value as bool);
    return valid;
  }
}
