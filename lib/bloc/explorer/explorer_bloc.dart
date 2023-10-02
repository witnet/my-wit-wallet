import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:witnet/schema.dart';

part 'explorer_event.dart';

part 'explorer_state.dart';

enum ExplorerStatus {
  unknown,
  dataloading,
  dataloaded,
  singleSync,
  error,
  ready,
}

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  late Stream syncWalletStream;
  // ignore: cancel_subscriptions
  StreamSubscription? syncWalletSubscription;

  ExplorerBloc(initialState) : super(initialState) {
    on<HashQueryEvent>(_hashQueryEvent);
    on<StatusQueryEvent>(_statusQueryEvent);
    on<AddressQueryEvent>(_addressQueryEvent);
    on<VTTransactionPostEvent>(_vtTransactionPostEvent);
    on<UtxoQueryEvent>(_utxoQueryEvent);
    on<SyncWalletEvent>(_syncWalletEvent);
    on<CancelSyncWalletEvent>(_cancelSyncEvent);
    on<SyncSingleAccountEvent>(_syncSingleAccount);
    on<DataLoadedEvent>(_emitDataLoadedStatus);
    on<DataLoadingEvent>(_emitDataLoadingStatus);
    on<SyncErrorEvent>(_emitSyncError);
  }

  static ExplorerState get initialState => ExplorerState.ready();

  Future<void> _hashQueryEvent(
      HashQueryEvent event, Emitter<ExplorerState> emit) async {
    try {
      var resp = await Locator.instance
          .get<ApiExplorer>()
          .hash(event.value, event.utxos);
      emit(ExplorerState.dataLoaded(data: resp, query: ExplorerQuery.hash));
    } catch (err) {
      emit(ExplorerState.error());
      rethrow;
    }
  }

  Future<void> _statusQueryEvent(
      StatusQueryEvent event, Emitter<ExplorerState> emit) async {
    Status resp = await Locator.instance.get<ApiExplorer>().getStatus();
    try {
      // TODO: fix type error in witnet.dart to get status
      if (resp.databaseMessage == 'Explorer backend seems healthy') {
        emit(ExplorerState.dataLoaded(
            data: resp.jsonMap(), query: ExplorerQuery.status));
      } else {
        emit(ExplorerState.error());
      }
    } catch (err) {
      emit(ExplorerState.error());
      rethrow;
    }
  }

  Future<void> _addressQueryEvent(
      AddressQueryEvent event, Emitter<ExplorerState> emit) async {
    try {
      var resp = await Locator.instance
          .get<ApiExplorer>()
          .address(value: event.address, tab: event.tab);
      emit(ExplorerState.dataLoaded(
          data: resp.jsonMap(), query: ExplorerQuery.address));
    } catch (err) {
      emit(ExplorerState.error());
      rethrow;
    }
  }

  Future<void> _vtTransactionPostEvent(
      VTTransactionPostEvent event, Emitter<ExplorerState> emit) async {
    try {
      var resp = await Locator.instance
          .get<ApiExplorer>()
          .sendVtTransaction(event.vtTransaction);

      emit(ExplorerState.dataLoaded(query: ExplorerQuery.sendVtt, data: resp));
    } catch (err) {
      emit(ExplorerState.error());
      rethrow;
    }
  }

  Future<void> _utxoQueryEvent(
      UtxoQueryEvent event, Emitter<ExplorerState> emit) async {
    try {
      var resp = await Locator.instance
          .get<ApiExplorer>()
          .utxos(address: event.account.address);
      var utxoList = {};
      resp.forEach((element) {
        utxoList[element.outputPointer.transactionId] = element;
      });

      emit(ExplorerState.dataLoaded(
          query: ExplorerQuery.utxos, data: {'utxos': utxoList}));
    } catch (e) {
      print('Error loading utxos $e');
      emit(ExplorerState.error());
      rethrow;
    }
  }

  void _emitDataLoadedStatus(event, emit) {
    emit(ExplorerState.synced(event.walletStorage));
  }

  void _emitDataLoadingStatus(_, emit) {
    emit(ExplorerState.dataLoading());
  }

  void _emitSyncError(_, emit) {
    emit(ExplorerState.error());
  }

  Future<void> _singleSyncEvent(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {
    try {
      add(DataLoadingEvent(ExplorerStatus.dataloading));
      add(DataLoadedEvent(
          ExplorerStatus.dataloaded, await syncWalletRoutine(event, emit)));
    } catch (e) {
      setError(e);
    }
  }

  void _cancelSyncEvent(
      CancelSyncWalletEvent event, Emitter<ExplorerState> emit) {
    if (syncWalletSubscription != null) syncWalletSubscription!.cancel();
  }

  Future<void> _syncWalletEvent(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {
    if (event.force) {
      await _singleSyncEvent(event, emit);
    } else {
      // Create a periodic stream for syncing the wallet
      syncWalletStream =
          Stream.periodic(Duration(seconds: SYNC_TIMER_IN_SECONDS), (_) {
        add(DataLoadingEvent(ExplorerStatus.dataloading));
        return syncWalletRoutine(event, emit);
      }).asyncMap((event) async => await event);
      if (syncWalletSubscription != null) syncWalletSubscription!.cancel();
      syncWalletSubscription = syncWalletStream.listen((event) {
        add(DataLoadedEvent(ExplorerStatus.dataloaded, event));
      }, onError: setError, cancelOnError: false);
    }
  }

  void setError(error) {
    print('Error syncing the wallet $error');
    if (syncWalletStream.isBroadcast) add(SyncErrorEvent(ExplorerStatus.error));
  }

  Future<void> _syncSingleAccount(
      SyncSingleAccountEvent event, Emitter<ExplorerState> emit) async {
    emit(ExplorerState.singleAccountSyncing(
        data: {"address": event.account.address}));

    ApiDatabase database = Locator.instance<ApiDatabase>();
    Wallet wallet = database.walletStorage.currentWallet;

    Account account = await updateAccountVttsAndBalance(event.account);
    wallet.updateAccount(
      index: account.index,
      keyType: account.keyType,
      account: account,
    );

    database.walletStorage.wallets[wallet.id] = wallet;
    await database.loadWalletsDatabase();
    await database.updateCurrentWallet(
        currentWalletId: wallet.id,
        isHdWallet: wallet.walletType == WalletType.hd);
    emit(ExplorerState.synced(database.walletStorage));
  }

  Future<dynamic> _getStatsByAddress(String address, String tab) async {
    try {
      return await Locator.instance
          .get<ApiExplorer>()
          .address(value: address, tab: tab);
    } catch (err) {
      print('Error getting $tab stats from master account $address :: $err');
      rethrow;
    }
  }

  Future<void> _saveStatsInDB(
      {required ApiDatabase database,
      required AccountStats statsToSave}) async {
    try {
      await database.addStats(statsToSave);
    } catch (err) {
      print('Error updating stats for adddress ${statsToSave.address} :: $err');
    }
  }

  Future<void> _updateStatsInDB(
      {required ApiDatabase database,
      required AccountStats statsToUpdate}) async {
    try {
      await database.updateStats(statsToUpdate);
    } catch (err) {
      print(
          'Error updating stats for adddress ${statsToUpdate.address} :: $err');
    }
  }

  Future<AddressBlocks?> getAddressBlocks({required String address}) async {
    try {
      final result =
          await _getStatsByAddress(address, MasterAccountStats.blocks.name);
      if (result.runtimeType != AddressBlocks && result['error'] != null) {
        print('Error getting address blocks: ${result['error']}');
        return null;
      }
      return result as AddressBlocks?;
    } catch (err) {
      print('Error getting address blocks: $err');
      rethrow;
    }
  }

  Future<AddressDataRequestsSolved?> getDataRequestsSolved(
      {required String address}) async {
    try {
      final result = await _getStatsByAddress(
          address, MasterAccountStats.data_requests_solved.name);
      if (result.runtimeType != AddressDataRequestsSolved &&
          result['error'] != null) {
        print('Error getting data requests solved: ${result['error']}');
        return null;
      }
      return result as AddressDataRequestsSolved?;
    } catch (err) {
      print('Error getting data requests solved: $err');
      rethrow;
    }
  }

  Future<AccountStats> getAccountStats(Wallet currentWallet) async {
    String address = currentWallet.masterAccount!.address;
    AddressDataRequestsSolved? dataRequestsSolved =
        await getDataRequestsSolved(address: address);

    List<MintEntry> blocks = currentWallet.allMints();
    int? feesPayed;
    int? totalRewards;
    if (blocks.length > 0) {
      feesPayed =
          blocks.map((block) => block.fees).reduce((fees, acc) => fees + acc);
      totalRewards =
          blocks.map((block) => block.reward).reduce((fees, acc) => fees + acc);
    }

    return AccountStats(
        walletId: currentWallet.id,
        address: address,
        totalBlocksMined: blocks.length,
        totalFeesPayed: feesPayed ?? 0,
        totalRewards: totalRewards ?? 0,
        totalDrSolved: dataRequestsSolved?.numDataRequestsSolved ?? 0);
  }

  Future<void> _updateDBStatsFromExplorerResult(
      {required Wallet currentWallet, required ApiDatabase database}) async {
    String address = currentWallet.masterAccount!.address;
    String walletId = currentWallet.id;
    try {
      // Get saved stats from db
      AccountStats? savedStatsByAddress =
          await database.getStatsByAddress(address);
      // Get new account data requests info from explorer
      AccountStats statsByAddressToSave = await getAccountStats(currentWallet);
      if (savedStatsByAddress != null &&
          savedStatsByAddress == statsByAddressToSave) {
        return;
      }
      if (savedStatsByAddress == null) {
        await _saveStatsInDB(
            database: database, statsToSave: statsByAddressToSave);
      } else {
        await _updateStatsInDB(
            database: database, statsToUpdate: statsByAddressToSave);
      }

      // Update stats in walletStorage
      database.walletStorage
          .setStats(walletId, savedStatsByAddress ?? statsByAddressToSave);
    } catch (err) {
      print('Error updating stats $err');
    }
  }

  Future<WalletStorage> syncWalletRoutine(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {
    /// get current wallet
    ApiDatabase database = Locator.instance<ApiDatabase>();
    Wallet wallet = database.walletStorage.currentWallet;

    /// get a list of any pending transactions
    List<ValueTransferInfo> unconfirmedVtts = [];
    wallet.allTransactions().forEach((vtt) {
      if (vtt.status != "confirmed") {
        unconfirmedVtts.add(vtt);
      }
    });

    if (wallet.walletType == WalletType.hd) {
      /// maintain gap limit for BIP39
      await wallet.ensureGapLimit();

      /// address limit is the limit of the explorer API for batching utxo calls
      int addressLimit = 10;
      List<List<String>> addressChunks = [];
      List<String> addressList = wallet.allAddresses();

      /// break the address list into chunks of 10 addresses
      for (int i = 0; i < addressList.length; i += addressLimit) {
        int end = (i + addressLimit < addressList.length)
            ? i + addressLimit
            : addressList.length;
        addressChunks.add([addressList.sublist(i, end).join(',')]);
      }

      /// get the UTXOs from the explorer
      try {
        for (int i = 0; i < addressChunks.length; i++) {
          Map<String, List<Utxo>> _utxos = {};
          try {
            _utxos = await Locator.instance<ApiExplorer>()
                .utxosMulti(addressList: addressChunks[i]);
          } catch (err) {
            print('Error getting UTXOs from the explorer $err');
            rethrow;
          }

          /// loop over the explorer response
          /// which is Map<String, List<Utxo>> key = address
          Map<String, Account> updatedAccounts = {};

          for (int addressIndex = 0;
              addressIndex < _utxos.length;
              addressIndex++) {
            String address = _utxos.keys.toList()[addressIndex];
            List<Utxo> utxoList = _utxos[address] ?? [];
            Account? account = wallet.accountByAddress(address);
            if (account != null && !account.sameUtxoList(utxoList)) {
              if (utxoList.isNotEmpty) {
                account.utxos = utxoList;
                account = await updateAccountVttsAndBalance(account);
              } else {
                account.utxos.clear();
              }
              updatedAccounts[account.address] = account;
              await wallet.updateAccount(
                  index: account.index,
                  keyType: account.keyType,
                  account: account);
            }
          }
          database.walletStorage.wallets[wallet.id] = wallet;
        }
      } catch (err) {
        print('Error updating UTXOs $err');
        rethrow;
      }
    } else if (wallet.walletType == WalletType.single) {
      await _updateDBStatsFromExplorerResult(
          currentWallet: wallet, database: database);

      List<Utxo> utxoList = await Locator.instance<ApiExplorer>()
          .utxos(address: wallet.masterAccount!.address);
      Account account = wallet.masterAccount!;

      if (!wallet.masterAccount!.sameUtxoList(utxoList)) {
        if (utxoList.isNotEmpty) {
          account.utxos = utxoList;
          account = await updateAccountVttsAndBalance(account);
        } else {
          account.utxos.clear();
        }
        wallet.updateAccount(
            index: account.index, keyType: account.keyType, account: account);
      }
      database.walletStorage.wallets[wallet.id] = wallet;
    }

    for (int i = 0; i < unconfirmedVtts.length; i++) {
      ValueTransferInfo _vtt = unconfirmedVtts[i];
      try {
        ValueTransferInfo vtt =
            await Locator.instance.get<ApiExplorer>().getVtt(_vtt.txnHash);
        if (_vtt.status != vtt.status) {
          await database.updateVtt(wallet.id, vtt);
        }
      } catch (e) {
        /// If the getVtt method returns null we enter this catch
        /// and the vtt has an unknown hash

        /// check the inputs for accounts in the wallet and remove the vtt
        for (int i = 0; i < _vtt.inputs.length; i++) {
          Account? account = wallet.accountByAddress(_vtt.inputs[i].address);
          if (account != null) {
            await account.deleteVtt(_vtt);
          }
        }

        /// check the outputs for accounts in the wallet and remove the vtt
        for (int i = 0; i < _vtt.outputs.length; i++) {
          Account? account =
              wallet.accountByAddress(_vtt.outputs[i].pkh.address);
          if (account != null) {
            await account.deleteVtt(_vtt);
          }
        }

        /// delete the stale vtt from the database.
        await database.deleteVtt(_vtt);
      }
    }
    await database.loadWalletsDatabase();
    await database.updateCurrentWallet(
        currentWalletId: wallet.id,
        isHdWallet: wallet.walletType == WalletType.hd);
    return database.walletStorage;
  }

  Future<Account> _syncMints(Account account) async {
    try {
      /// retrieve all Block Hashes
      ApiExplorer explorer = Locator.instance.get<ApiExplorer>();
      final addressBlocks = await explorer.address(
          value: account.address, tab: 'blocks') as AddressBlocks;

      /// check if the list of transaction is already in the database
      for (int i = 0; i < addressBlocks.blocks.length; i++) {
        ApiDatabase database = Locator.instance.get<ApiDatabase>();
        String blockHash = addressBlocks.blocks[i].blockID;
        MintEntry? mintEntry = database.walletStorage.getMint(blockHash);
        BlockInfo blockInfo = addressBlocks.blocks.elementAt(i);

        if (mintEntry != null) {
          /// this mintEntry.status check for "confirmed" is in the local database
          if (mintEntry.status != "confirmed") {
            MintEntry mintEntry = await explorer.getMint(blockInfo);
            await account.addMint(mintEntry);
          }
        } else {
          MintEntry mintEntry = await explorer.getMint(blockInfo);
          await account.addMint(mintEntry);
        }
      }

      account.mintHashes.clear();
      account.mintHashes
          .addAll(addressBlocks.blocks.map((block) => block.blockID));

      return account;
    } catch (e) {
      print('Error syncing mints $e');
      rethrow;
    }
  }

  Future<Account> updateAccountVttsAndBalance(Account account) async {
    try {
      AddressValueTransfers vtts = await Locator.instance
          .get<ApiExplorer>()
          .address(value: account.address, tab: 'value_transfers');

      /// check if the list of transaction is already in the database
      ApiDatabase database = Locator.instance.get<ApiDatabase>();
      for (int i = 0; i < vtts.transactionHashes.length; i++) {
        String transactionId = vtts.transactionHashes[i];
        ValueTransferInfo? vtt = database.walletStorage.getVtt(transactionId);

        if (vtt != null) {
          /// this vtt.status check for "confirmed" is in the local database
          if (vtt.status != "confirmed") {
            ValueTransferInfo _vtt =
                await Locator.instance.get<ApiExplorer>().getVtt(transactionId);
            await account.addVtt(_vtt);
          }
        } else {
          ValueTransferInfo vtt =
              await Locator.instance.get<ApiExplorer>().getVtt(transactionId);
          await account.addVtt(vtt);
        }
      }

      account.vttHashes.clear();
      account.vttHashes.addAll(vtts.transactionHashes);
      if (account.keyType == KeyType.master) {
        account = await _syncMints(account);
      }
      await account.setBalance();
      database.walletStorage.wallets[account.walletId]!.setAccount(account);
    } catch (e) {
      print('Error updating account vtts and balance $e');
      rethrow;
    }
    return account;
  }
}
