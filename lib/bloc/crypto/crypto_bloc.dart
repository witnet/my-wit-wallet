import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_repository.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:my_wit_wallet/bloc/crypto/api_crypto.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:my_wit_wallet/util/storage/database/encrypt/password.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';
part 'crypto_isolate.dart';

Future<dynamic> isolateRunner(
    String method, Map<String, dynamic> params) async {
  ReceivePort response = ReceivePort();

  /// send the request
  Locator.instance<CryptoIsolate>()
      .send(method: method, params: params, port: response.sendPort);
  return await response.first;
}

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  ApiExplorer apiExplorer = Locator.instance.get<ApiExplorer>();
  ApiDatabase db = Locator.instance.get<ApiDatabase>();

  CryptoBloc(initialState) : super(initialState) {
    on<CryptoInitializeWalletEvent>(_cryptoInitializeWalletEvent);
    on<CryptoInitWalletDoneEvent>(_cryptoInitWalletDoneEvent);
    on<CryptoReadyEvent>(_cryptoReadyEvent);
    on<CryptoExceptionEvent>(_cryptoExceptionEvent);
  }

  Future<void> _cryptoInitializeWalletEvent(
      CryptoInitializeWalletEvent event, Emitter<CryptoState> emit) async {
    /// setup default default structure for database and unlock it
    emit(
      CryptoInitializingWalletState(
        message: 'Initializing Wallet.',
        availableNanoWit: 0,
        lockedNanoWit: 0,
        transactionCount: 0,
        addressCount: 0,
      ),
    );
    Wallet _wallet = await _initializeWallet(event: event);
    Map<int, Account> externalAccounts = {};
    Map<int, Account> internalAccounts = {};

    int totalTransactions = 0;
    int bufferTime = EXPLORER_DELAY_MS;
    BalanceInfo balance = BalanceInfo(availableUtxos: [], lockedUtxos: []);
    Account? _account;
    /// Account discovery
    /// (1)- derive the first account's node (index = 0)
    /// (2)- derive the external chain node of this account
    /// (3)- scan addresses of the external chain; respect the gap limit described below
    /// (4)- if no transactions are found on the external chain, stop discovery
    /// (5)- if there are some transactions, increase the account index and go to step 1
    /// reference (https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)

    if (_wallet.walletType == WalletType.hd) {
      /// search the External keychain for accounts with past transactions
      /// requirement: 20 consecutive accounts without transactions
      int externalGapCount = 0;
      final int externalGapMax = EXTERNAL_GAP_LIMIT;
      int externalIndex = 0;
      while (externalGapCount < externalGapMax) {
        /// wait to not overload the explorer
        try {
          _account = await _initAccount(
            _wallet,
            externalIndex,
            KeyType.external,
          );
        } catch (e) {
          _deleteWallet(_wallet);
          print('Error initializing external accounts $e');
          return;
        }

        totalTransactions += _account.vttHashes.length;
        _wallet.externalAccounts[externalIndex] = _account;
        balance = balance + _account.balance;

        /// yield a state with the current account for ui display
        /// pass the wallet but not the password since we are already logged in
        emit(CryptoInitializingWalletState(
          message: '${_account.address}',
          availableNanoWit: balance.availableNanoWit,
          lockedNanoWit: balance.lockedNanoWit,
          transactionCount: totalTransactions,
          addressCount: externalIndex,
        ));

        /// if the account has 0 past transactions, increase the gap counter
        /// add the account
        externalAccounts[externalIndex] = _account;
        externalIndex += 1;
        if (_account.vttHashes.length == 0) {
          externalGapCount += 1;
        }
      }

      /// search the Internal keychain for accounts with past transactions
      /// requirement: 1 consecutive account without transactions
      int internalGapCount = 0;
      final int internalGapMax = INTERNAL_GAP_LIMIT;
      int internalIndex = 0;
      while (internalGapCount < internalGapMax) {
        /// wait to not overload the explorer
        await Future.delayed(Duration(milliseconds: bufferTime));

        try {
          _account = await _initAccount(
            _wallet,
            internalIndex,
            KeyType.internal,
          );
        } catch (e) {
          _deleteWallet(_wallet);
          print('Error initializing internal accounts $e');
          return;
        }

        _wallet.internalAccounts[internalIndex] = _account;
        totalTransactions += _account.vttHashes.length;
        balance = balance + _account.balance;

        /// yield a state with the current account for ui display

        emit(CryptoInitializingWalletState(
          message: '${_account.address}',
          availableNanoWit: balance.availableNanoWit,
          lockedNanoWit: balance.lockedNanoWit,
          transactionCount: totalTransactions,
          addressCount: externalIndex + internalIndex,
        ));

        /// if the account has 0 past transactions, increase the gap counter
        if (_account.vttHashes.length == 0) {
          internalGapCount += 1;
        } else {}

        /// add the account
        internalAccounts[internalIndex] = _account;
        internalIndex += 1;
      }

      if (externalAccounts[0]!.address != '') {}
    } else if (_wallet.walletType == WalletType.single) {
      try {
        _account = await _initAccount(
          _wallet,
          0,
          KeyType.master,
        );
        _wallet.masterAccount = _account;

        balance = balance + _account.balance;
        emit(CryptoInitializingWalletState(
          message: '${_account.address}',
          availableNanoWit: balance.availableNanoWit,
          lockedNanoWit: balance.lockedNanoWit,
          transactionCount: _account.vttHashes.length,
          addressCount: 1,
        ));
      } catch (e) {
        _deleteWallet(_wallet);
        print('Error initializing single account $e');
        return;
      }
    }
    ApiDatabase database = Locator.instance.get<ApiDatabase>();
    //database.walletStorage.wallets[_wallet.id] = _wallet;
    database.walletStorage.setCurrentWallet(_wallet.id);
    await database.loadWalletsDatabase();
    await database.updateCurrentWallet(
        currentWalletId: _wallet.id, isNewWallet: true);
    add(CryptoInitWalletDoneEvent(
      wallet: _wallet,
      password: event.password,
      internalAccounts: internalAccounts,
      externalAccounts: externalAccounts,
    ));
  }

  Future<void> _cryptoInitWalletDoneEvent(
    CryptoInitWalletDoneEvent event,
    Emitter<CryptoState> emit,
  ) async {
    Wallet wallet = event.wallet;
    emit(CryptoLoadedWalletState(
      wallet: wallet,
      password: event.password,
    ));

    // clear the temporary data used to create the wallet
    Locator.instance<ApiCreateWallet>().clearFormData();
  }

  void _cryptoReadyEvent(CryptoReadyEvent event, Emitter<CryptoState> emit) {
    emit(CryptoReadyState());
  }

  void _cryptoExceptionEvent(
      CryptoExceptionEvent event, Emitter<CryptoState> emit) {
    emit(CryptoExceptionState(
      code: event.code,
      message: event.message,
    ));
  }

  get initialState => CryptoReadyState();

  Future<Wallet> _initializeWallet(
      {required CryptoInitializeWalletEvent event}) async {
    ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
    ApiDatabase db = Locator.instance<ApiDatabase>();
    String key = await db.getKeychain();
    final masterKey = key != '' ? key : event.password;
    apiCrypto.setInitialWalletData(
      event.walletName,
      event.keyData,
      event.seedSource,
      masterKey,
      event.walletType,
    );

    final Wallet _wallet = await apiCrypto.initializeWallet();
    var creationStatus = await db.openDatabase();
    assert(creationStatus, 'Unable to Create Database.');
    await db.addWallet(_wallet);
    db.walletStorage.wallets[_wallet.id] = _wallet;
    return _wallet;
  }

  Future<bool> _deleteWallet(Wallet _wallet) async {
    return await db.deleteWallet(_wallet);
  }

  Future<Account> _generateAccount(
      Wallet wallet, int index, KeyType keyType) async {
    try {
      ApiCrypto apiCrypto = Locator.instance.get<ApiCrypto>();
      final Account account =
          await apiCrypto.generateAccount(wallet, keyType, index);
      return account;
    } catch (e) {
      rethrow;
    }
  }

  Future<Account> _initAccount(
      Wallet wallet, int index, KeyType keyType) async {
    try {
      Account account = await _generateAccount(wallet, index, keyType);
      account = await _syncAccount(account);
      account = await _syncVtts(account);
      if (account.keyType == KeyType.master) {
        account = await _syncMints(account);
      }
      await account.setBalance();
      await db.addAccount(account);
      return account;
    } catch (e) {
      add(CryptoExceptionEvent(code: 404, message: 'ConnectionError '));
      rethrow;
    }
  }

  Future<Account> _syncVtts(Account account) async {
    try {
      for (int i = 0; i < account.vttHashes.length; i++) {
        String _hash = account.vttHashes.elementAt(i);
        var result = await apiExplorer.hash(_hash);
        ValueTransferInfo valueTransferInfo = result as ValueTransferInfo;
        account.vtts.add(valueTransferInfo);
        await db.addVtt(valueTransferInfo);
      }
      return account;
    } catch (e) {
      print('Error syncing vtts $e');
      rethrow;
    }
  }

  Future<Account> _syncMints(Account account) async {
    try {
      /// retrieve any Block Hashes
      final addressBlocks = await apiExplorer.address(
          value: account.address, tab: 'blocks') as AddressBlocks;

      /// retrieve each block
      for (int i = 0; i < addressBlocks.blocks.length; i++) {
        BlockInfo blockInfo = addressBlocks.blocks.elementAt(i);
        String _hash = blockInfo.blockID;
        var result = await apiExplorer.hash(_hash);

        /// create a MintEntry from the BlockInfo and MintInfo
        BlockDetails blockDetails = result as BlockDetails;
        MintEntry mintEntry = MintEntry.fromBlockMintInfo(
          blockInfo,
          blockDetails.mintInfo,
        );
        account.mintHashes.add(mintEntry.blockHash);
        account.mints.add(mintEntry);
        await db.addMint(mintEntry);
      }
      return account;
    } catch (e) {
      print('Error syncing mints $e');
      rethrow;
    }
  }

  Future<Account> _syncAccount(Account account) async {
    try {
      final addressValueTransfers = await apiExplorer.address(
          value: account.address,
          tab: 'value_transfers') as AddressValueTransfers;
      account.vttHashes = List<String>.from(
          addressValueTransfers.transactionHashes.map((e) => e));
      final List<Utxo> _utxos =
          await apiExplorer.utxos(address: account.address);
      account.utxos.addAll(_utxos);
      await account.setBalance();
      return account;
    } catch (e) {
      print('Error syncing the account: ${account.address} $e');
      rethrow;
    }
  }
}
