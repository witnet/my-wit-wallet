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
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

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
  CryptoInitializingWalletState({
    required this.message,
  });
}

class CryptoLoadedWalletState extends CryptoState {
  final Wallet wallet;
  final String password;

  CryptoLoadedWalletState({required this.wallet, required this.password});
}

class CryptoLoadingState extends CryptoState {}

class CryptoLoadedState extends CryptoState {}

class CryptoErrorState extends CryptoState {
  CryptoErrorState({required this.exception});

  final CryptoException exception;
}

Future<Map<String, dynamic>> initWalletRunner(
    CryptoInitializeWalletEvent event) async {
  print('Runner:');
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
  // initialize the crypto isolate if not already done so
  if (!Locator.instance<CryptoIsolate>().initialized)
    await Locator.instance<CryptoIsolate>().init();
  // send the request
  Locator.instance<CryptoIsolate>()
      .send(method: method, params: params, port: response.sendPort);
  //
  return await response.first;
}

class BlocCrypto extends Bloc<CryptoEvent, CryptoState> {
  BlocCrypto(initialState) : super(initialState);

  get initialState => CryptoReadyState();

  @override
  Stream<CryptoState> mapEventToState(CryptoEvent event) async* {
    try {
      switch (event.runtimeType) {
        case CryptoInitializeWalletEvent:
          event as CryptoInitializeWalletEvent;
          ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();

          apiCrypto.setInitialWalletData(
              event.walletName,
              event.walletDescription,
              event.keyData,
              event.seedSource,
              event.password);
          yield CryptoInitializingWalletState(message: 'Initializing Wallet.');

          Wallet _wallet = await isolateRunner('initializeWallet', {
            'walletName': event.walletName,
            'walletDescription': event.walletDescription,
            'seed': event.keyData,
            'seedSource': event.seedSource,
            'password': event.password,
          });
          ApiExplorer apiExplorer = ApiExplorer();
          TransactionCache cache = TransactionCache();
          int externalGapCount = 0;
          int externalGapMax = 20;
          int externalIndex = 0;

          int internalGapCount = 0;
          int internalGapMax = 1;
          int internalIndex = 0;
          Map<int, Account> externalAccounts = {};
          Map<int, Account> internalAccounts = {};

          Map<String, dynamic> transactionHashes = {};

          int bufferTime = 100;

          while (externalGapCount < externalGapMax) {
            /// wait to not overload the explorer
            await Future.delayed(Duration(milliseconds: bufferTime));

            // the Wallet.getKey uses the crypto isolate internally
            Xprv xprv = await _wallet.getKey(
                index: externalIndex, keyType: KeyType.external);
            String _addressStr = xprv.address.address;
            String _path = xprv.path!;
            Account account = Account(address: _addressStr, path: _path);
            yield CryptoInitializingWalletState(
                message: '${account.path} ${account.address}');

            ////
            AddressValueTransfers addressValueTransfers = await apiExplorer
                    .address(value: account.address, tab: 'value_transfers')
                as AddressValueTransfers;

            for (int i = 0; i < addressValueTransfers.numValueTransfers; i++) {
              String transactionID = addressValueTransfers.transactionHashes[i];
              if (cache.containsHash(transactionID)) {
                account.valueTransfers[transactionID] =
                    cache.getVtt(transactionID);
              } else {
                await Future.delayed(Duration(milliseconds: bufferTime));
                Stopwatch stopwatch = new Stopwatch()..start();
                ValueTransferInfo vti;
                if (cache.containsHash(transactionID)) {
                  vti = cache.getVtt(transactionID);
                  print('using cache');
                } else {
                  vti = await apiExplorer.hash(transactionID, true)
                      as ValueTransferInfo;
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

            if (addressValueTransfers.numValueTransfers == 0) {
              externalGapCount += 1;
            } else {}
            ////
            externalAccounts[externalIndex] = account;
            ////
            /////////////////////////
            ////
            //Address address = Address(address: _addressStr);
            //address.getUtxoInfo(source: apiExplorer);
            ////
            externalIndex += 1;
          }
          //////////////////////////////////////////////////////////////////////
          //////////////////////////////////////////////////////////////////////
          while (internalGapCount < internalGapMax) {
            /// wait to not overload the explorer
            await Future.delayed(Duration(milliseconds: bufferTime));

            // the Wallet.getKey uses the crypto isolate internally
            Xprv xprv = await _wallet.getKey(
                index: internalIndex, keyType: KeyType.internal);
            String _addressStr = xprv.address.address;
            String _path = xprv.path!;
            Account account = Account(address: _addressStr, path: _path);
            yield CryptoInitializingWalletState(
                message: '${account.path} ${account.address}');

            AddressValueTransfers addressValueTransfers = await apiExplorer
                    .address(value: account.address, tab: 'value_transfers')
                as AddressValueTransfers;

            for (int i = 0; i < addressValueTransfers.numValueTransfers; i++) {
              String transactionID = addressValueTransfers.transactionHashes[i];
              if (cache.containsHash(transactionID)) {
                account.valueTransfers[transactionID] =
                    cache.getVtt(transactionID);
              } else {
                await Future.delayed(Duration(milliseconds: bufferTime));
                Stopwatch stopwatch = new Stopwatch()..start();
                ValueTransferInfo vti;
                if (cache.containsHash(transactionID)) {
                  vti = cache.getVtt(transactionID);
                } else {
                  vti = await apiExplorer.hash(transactionID, true)
                      as ValueTransferInfo;
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

            if (addressValueTransfers.numValueTransfers == 0) {
              internalGapCount += 1;
            } else {}
            ////
            internalAccounts[internalIndex] = account;
            ////
            /////////////////////////
            ////
            //Address address = Address(address: _addressStr);
            //address.getUtxoInfo(source: apiExplorer);
            ////
            internalIndex += 1;


          }
          //////////////////////////////////////////////////////////////////////
          //////////////////////////////////////////////////////////////////////

          //Map<String, dynamic> initResp = await initWalletRunner(event);
          //
          // Wallet wallet = initResp['wallet'];

          for (int i = 0; i < externalAccounts.keys.length; i++) {
            int key = externalAccounts.keys.elementAt(i);
            Account account = externalAccounts[key]!;
            List<Utxo> utxos =
                await apiExplorer.utxos(address: account.address);
            account.utxos.addAll(utxos);
            externalAccounts[key] = account;
          }
          for (int i = 0; i < internalAccounts.keys.length; i++) {
            int key = internalAccounts.keys.elementAt(i);
            Account account = internalAccounts[key]!;
            List<Utxo> utxos =
                await apiExplorer.utxos(address: account.address);
            account.utxos.addAll(utxos);
            internalAccounts[key] = account;
          }
          add(CryptoInitWalletDoneEvent(
              wallet: _wallet,
              password: event.password,
              internalAccounts: internalAccounts,
              externalAccounts: externalAccounts));
          break;
        case CryptoInitWalletDoneEvent:
          event as CryptoInitWalletDoneEvent;
          Wallet wallet = event.wallet;
          var db = Locator.instance<ApiDatabase>();
          Locator.instance<ApiAuth>().setWalletName(wallet.name);
          var creationStatus = await db.createDatabase(
              path: wallet.name, password: event.password);
          await db.unlockDatabase(name: wallet.name, password: event.password);
          Map<String, dynamic> masterNode = {
            'address': wallet.masterXprv.address.address,
            'path': wallet.masterXprv.path,
            'balance': 0,
            'value_transfer_transactions': {},
            'last_synced': -1,
          };
          Map<String, dynamic> _extAccounts = {};
          event.externalAccounts.forEach((key, value) {
            _extAccounts[value.address] = value.jsonMap();
            print(value.address);
          });
          Map<String, dynamic> _intAccounts = {};
          event.internalAccounts.forEach((key, value) {
            _intAccounts[value.address] = value.jsonMap();
          });
          await db.writeDatabaseRecord(
              key: 'xprv',
              value: event.wallet.masterXprv
                  .toEncryptedXprv(password: event.password));
          await db.writeDatabaseRecord(key: 'master_node', value: masterNode);
          await db.writeDatabaseRecord(
              key: 'external_accounts', value: _extAccounts);
          await db.writeDatabaseRecord(
              key: 'internal_accounts', value: _intAccounts);
          await db.writeDatabaseRecord(key: 'last_synced', value: -1);

          yield CryptoLoadedWalletState(
              wallet: event.wallet, password: event.password);
          // clear the temporary data used to create the wallet
          Locator.instance<ApiCreateWallet>().clearFormData();

          break;
      }
    } on CryptoException catch (e) {
      yield CryptoErrorState(exception: e);
    }
  }
}
