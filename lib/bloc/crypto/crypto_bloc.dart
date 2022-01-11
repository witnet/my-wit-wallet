import 'dart:isolate';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/api_crypto.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/shared/api_auth.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/cache/file_manager_interface.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

import '../../constants.dart';
import 'crypto_isolate.dart';

/// CryptoException
class CryptoException {
  CryptoException({required this.code, required this.message});
  final int code;
  final String message;
}

/// Events
abstract class CryptoEvent {}

class CryptoInitializeWalletEvent extends CryptoEvent {
  String walletName;
  String walletDescription;
  String keyData;
  String password;
  String seedSource;

  CryptoInitializeWalletEvent(
      {required this.walletDescription,
      required this.walletName,
      required this.keyData,
      required this.seedSource,
      required this.password,
      int addressCount = 10});
}

class CryptoReadyEvent extends CryptoEvent {}

class CryptoComputeEvent extends CryptoEvent {}

class CryptoDoneEvent extends CryptoEvent {}

class CryptoInitWalletDoneEvent extends CryptoEvent {
  final Wallet wallet;
  final String password;
  final Map<int, Account> externalAccounts;
  final Map<int, Account> internalAccounts;

  CryptoInitWalletDoneEvent({
    required this.wallet,
    required this.password,
    required this.internalAccounts,
    required this.externalAccounts,
  });
}

class CryptoErrorEvent extends CryptoEvent {}

/// States
abstract class CryptoState {}

class CryptoReadyState extends CryptoState {}

class CryptoInitializingWalletState extends CryptoState {
  final String message;
  final int balanceNanoWit;
  final int transactionCount;
  final int addressCount;

  CryptoInitializingWalletState(
      {required this.message,
      required this.balanceNanoWit,
      required this.transactionCount,
      required this.addressCount});
}

class CryptoLoadedWalletState extends CryptoState {
  final Wallet wallet;
  final String password;

  final DbWallet dbWallet;
  CryptoLoadedWalletState(
      {required this.wallet,
      required this.password,
      required this.dbWallet});
}

class CryptoLoadingState extends CryptoState {}

class CryptoLoadedState extends CryptoState {}

class CryptoErrorState extends CryptoState {
  CryptoErrorState({required this.exception});

  final CryptoException exception;
}

Future<Map<String, dynamic>> initWalletRunner(
    CryptoInitializeWalletEvent event) async {

  ReceivePort resp = ReceivePort();
  if (!Locator.instance<CryptoIsolate>().initialized)
    await Locator.instance<CryptoIsolate>().init();
  Locator.instance<CryptoIsolate>().send(
      method: 'initializeWallet',
      params: {
        'walletName': event.walletName,
        'walletDescription': event.walletDescription,
        'seed': event.keyData,
        'seedSource': event.seedSource,
        'password': event.password,
      },
      port: resp.sendPort);

  Map<String, dynamic> data = await resp.first.then((value) {
    return {
      'wallet': value['wallet'] as Wallet,
      'external_accounts': value['external_accounts'],
      'internal_accounts': value['internal_accounts'],
      'cache': value['cache'],
    };
  });
  resp.close();
  return data;
}

Future<dynamic> isolateRunner(
    String method, Map<String, dynamic> params) async {
  ReceivePort response = ReceivePort();

  /// initialize the crypto isolate if not already done so
  if (!Locator.instance<CryptoIsolate>().initialized)
    await Locator.instance<CryptoIsolate>().init();

  /// send the request
  Locator.instance<CryptoIsolate>()
      .send(method: method, params: params, port: response.sendPort);
  //
  return await response.first;
}

class BlocCrypto extends Bloc<CryptoEvent, CryptoState> {
  ApiExplorer apiExplorer = Locator.instance.get<ApiExplorer>();
  TransactionCache cache = Locator.instance.get<TransactionCache>();
  BlocCrypto(initialState) : super(initialState);

  get initialState => CryptoReadyState();

  Future<Wallet?> _initializeWallet(
      {required CryptoInitializeWalletEvent event}) async {
    try {
      ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
      apiCrypto.setInitialWalletData(event.walletName, event.walletDescription,
          event.keyData, event.seedSource, event.password);
      final _wallet = await isolateRunner('initializeWallet', {
        'walletName': event.walletName,
        'walletDescription': event.walletDescription,
        'seed': event.keyData,
        'seedSource': event.seedSource,
        'password': event.password,
      });
      apiCrypto.clearInitialWalletData();
      if (_wallet is Wallet) {
        var db = Locator.instance<ApiDatabase>();
        Locator.instance<ApiAuth>().setWalletName(_wallet.name);
        ///
        var creationStatus = await db.createDatabase(
            path: _wallet.name,
            password: event.password
        );
        assert (creationStatus, 'Unable to Create Database.');
        ///
        await db.unlockDatabase(name: _wallet.name, password: event.password);
        await db.writeDatabaseRecord(
          key: 'xprv',
          value: _wallet.masterXprv.toEncryptedXprv(password: event.password),
        );
        Map<String, dynamic> masterNode = {
          'address': _wallet.masterXprv.address.address,
          'path': _wallet.masterXprv.path,
          'balance': 0,
          'value_transfer_transactions': {},
          'last_synced': -1,
        };
        await db.writeDatabaseRecord(key: 'master_node', value: masterNode);
        await db.writeDatabaseRecord(key: 'external_accounts', value: {});
        await db.writeDatabaseRecord(key: 'internal_accounts', value: {});
        await db.writeDatabaseRecord(key: 'last_synced', value: -1);
        return _wallet;
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<Account> _generateAccount(Wallet wallet,int index, KeyType keyType) async {
    final Xpub xpub = await wallet.getXpub(index: index, keyType: keyType);
    final String _addressStr = xpub.address;
    final String _path = xpub.path!;
    final Account account = Account(address: _addressStr, path: _path);
    final addressValueTransfers = await apiExplorer.address(
        value: account.address,
        tab: 'value_transfers') as AddressValueTransfers;
    List<String> transactionHashes = List<String>.from(addressValueTransfers.transactionHashes.map((e) => e));
    //addressValueTransfers.jsonMap();
    account.vttHashes.addAll(transactionHashes);
    account.utxos = await _syncAccountUtxos(account);
    account.setBalance();

    return account;
  }


  Future<List<Utxo>> _syncAccountUtxos(Account account) async {
    final List<Utxo> _utxos = await apiExplorer.utxos(address: account.address);
    return _utxos;
  }

  Future<void> syncAccountValueTransfers(Account account) async {
    int bufferTime = EXPLORER_DELAY_MS;

    final addressValueTransfers = await apiExplorer.address(
        value: account.address,
        tab: 'value_transfers') as AddressValueTransfers;
    for (int i = 0; i < addressValueTransfers.numValueTransfers; i++) {
      String transactionID = addressValueTransfers.transactionHashes[i];
      if (cache.containsHash(transactionID)) {
        account.valueTransfers[transactionID] = cache.getVtt(transactionID);
      } else {
        await Future.delayed(Duration(milliseconds: bufferTime));
        Stopwatch stopwatch = new Stopwatch()..start();
        ValueTransferInfo vti;
        if (cache.containsHash(transactionID)) {
          vti = cache.getVtt(transactionID);
          } else {
          vti =
              await apiExplorer.hash(transactionID, true) as ValueTransferInfo;
        }

        // adjust time to not overload explorer
        int explorerResponseTime = stopwatch.elapsedMilliseconds;
        if (explorerResponseTime > bufferTime) {
          bufferTime = explorerResponseTime;
        } else
          bufferTime = 300;
        //store in cache
        cache.addVtt(vti);
        account.valueTransfers[transactionID] = vti;
      }
    }
    await cache.updateCache();
  }




  @override
  Stream<CryptoState> mapEventToState(CryptoEvent event) async* {
    try {
      switch (event.runtimeType) {
        case CryptoInitializeWalletEvent:
          event as CryptoInitializeWalletEvent;
          /// setup default default structure for database and and unlock it
          Wallet? _wallet = await _initializeWallet(event: event);




          yield CryptoInitializingWalletState(
            addressCount: 0,
            balanceNanoWit: 0,
            transactionCount: 0,
            message: 'Initializing Wallet.',
          );

          /// Account discovery
          /// (1)- derive the first account's node (index = 0)
          /// (2)- derive the external chain node of this account
          /// (3)- scan addresses of the external chain; respect the gap limit described below
          /// (4)- if no transactions are found on the external chain, stop discovery
          /// (5)- if there are some transactions, increase the account index and go to step 1
          /// reference (https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)

          int externalGapCount = 0;
          int externalGapMax = EXTERNAL_GAP_LIMIT;
          int externalIndex = 0;

          int internalGapCount = 0;
          int internalGapMax = INTERNAL_GAP_LIMIT;
          int internalIndex = 0;
          Map<int, Account> externalAccounts = {};
          Map<int, Account> internalAccounts = {};

          int totalTransactions = 0;
          int bufferTime = EXPLORER_DELAY_MS;
          int balance = 0;

          /// search the External keychain for accounts with past transactions
          /// requirement: 20 consecutive accounts without transactions
          while (externalGapCount < externalGapMax) {

            /// wait to not overload the explorer
            await Future.delayed(Duration(milliseconds: bufferTime));

            try{

            Account _account = await _generateAccount(_wallet!, externalIndex, KeyType.external);
            ///
            totalTransactions += _account.vttHashes.length;
            if (_account.vttHashes.length == 0) {
              externalGapCount += 1;
            }
            balance += _account.balance;
            /// yield a state with the current account for ui display
            /// pass the wallet but not the password since we are already logged in
            yield CryptoInitializingWalletState(
              addressCount: externalIndex + internalIndex,
              balanceNanoWit: balance,
              transactionCount: totalTransactions,
              message: '${_account.address}',
            );
            /// if the account has 0 past transactions, increase the gap counter
            /// add the account
            externalAccounts[externalIndex] = _account;
            externalIndex += 1;
            } catch (e){

            }


          }

          /// search the Internal keychain for accounts with past transactions
          /// requirement: 1 consecutive account without transactions
          while (internalGapCount < internalGapMax) {
            /// wait to not overload the explorer
            await Future.delayed(Duration(milliseconds: bufferTime));

            Account _intAccount = await _generateAccount(_wallet!, internalIndex, KeyType.internal);

            totalTransactions += _intAccount.vttHashes.length;
            balance += _intAccount.balance;

            /// yield a state with the current account for ui display
            yield CryptoInitializingWalletState(
              addressCount: externalIndex + internalIndex,
              balanceNanoWit: balance,
              transactionCount: totalTransactions,
              message: '${_intAccount.address}',
            );

            /// if the account has 0 past transactions, increase the gap counter
            if (_intAccount.vttHashes.length == 0) {
              internalGapCount += 1;
            } else {}

            /// add the account
            internalAccounts[internalIndex] = _intAccount;
            internalIndex += 1;
          }

          add(CryptoInitWalletDoneEvent(
              wallet: _wallet!,
              password: event.password,
              internalAccounts: internalAccounts,
              externalAccounts: externalAccounts));
          break;
        case CryptoInitWalletDoneEvent:
          event as CryptoInitWalletDoneEvent;
          Wallet wallet = event.wallet;
          var db = Locator.instance<ApiDatabase>();
          bool unlocked = await Locator.instance<ApiDatabase>().unlockDatabase(name: wallet.name, password: event.password);

          assert(unlocked);


          DbWallet dbWallet = DbWallet(
              xprv: event.wallet.masterXprv
                  .toEncryptedXprv(password: event.password),
              externalXpub: event.wallet.externalXpub.toSlip32(),
              internalXpub: event.wallet.internalXpub.toSlip32(),
              walletName: event.wallet.name,
              walletDescription: (event.wallet.description == null)
                  ? ''
                  : event.wallet.description!,
              externalAccounts: event.externalAccounts,
              internalAccounts: event.internalAccounts,
              lastSynced: DateTime.now().millisecondsSinceEpoch);
          await db.saveDbWallet(dbWallet);

          yield CryptoLoadedWalletState(
              wallet: event.wallet,
              password: event.password,
          dbWallet: dbWallet);
          // clear the temporary data used to create the wallet
          Locator.instance<ApiCreateWallet>().clearFormData();

          break;
        case CryptoReadyEvent:
          yield CryptoReadyState();
          break;
      }
    } on CryptoException catch (e) {
      yield CryptoErrorState(exception: e);
    }
  }


}
