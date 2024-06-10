import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/constants.dart';

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
  ApiExplorer explorer = Locator.instance.get<ApiExplorer>();
  ApiDatabase database = Locator.instance.get<ApiDatabase>();

  ExplorerBloc(initialState) : super(initialState) {
    on<HashQueryEvent>(_hashQueryEvent);
    on<StatusQueryEvent>(_statusQueryEvent);
    on<AddressQueryEvent>(_addressQueryEvent);
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
      emit(ExplorerState.error(message: 'HashQueryEvent error: $err'));
      rethrow;
    }
  }

  Future<void> _statusQueryEvent(
      StatusQueryEvent event, Emitter<ExplorerState> emit) async {
    Status resp = await explorer.getStatus();
    try {
      // TODO: fix type error in witnet.dart to get status
      if (resp.databaseMessage == 'Explorer backend seems healthy') {
        emit(ExplorerState.dataLoaded(
            data: resp.jsonMap(), query: ExplorerQuery.status));
      } else {
        emit(
            ExplorerState.error(message: 'Explorer backend seems not healthy'));
      }
    } catch (err) {
      emit(ExplorerState.error(message: 'StatusQueryEvent error: $err'));
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
          data: resp.data.jsonMap(), query: ExplorerQuery.address));
    } catch (err) {
      emit(ExplorerState.error(message: 'AddressQueryEvent error: $err'));
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
      emit(ExplorerState.error(message: 'UtxoQueryEvent error: $e'));
      rethrow;
    }
  }

  void _emitDataLoadedStatus(event, emit) {
    emit(ExplorerState.synced(event.walletStorage));
  }

  void _emitDataLoadingStatus(_, emit) {
    emit(ExplorerState.dataLoading());
  }

  void _emitSyncError(event, emit) {
    emit(ExplorerState.error(message: event.message));
  }

  Future<void> _singleSyncEvent(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {
    try {
      if (event.status != ExplorerStatus.error) {
        add(DataLoadingEvent(ExplorerStatus.dataloading));
      }
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
        if (event.status != ExplorerStatus.error) {
          add(DataLoadingEvent(ExplorerStatus.dataloading));
        }
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
    dynamic errorMessage = error;
    if (errorMessage.runtimeType == ExplorerException) {
      errorMessage = (errorMessage as ExplorerException).message;
    }
    add(SyncErrorEvent(ExplorerStatus.error, errorMessage));
  }

  Future<void> _syncSingleAccount(
      SyncSingleAccountEvent event, Emitter<ExplorerState> emit) async {
    emit(ExplorerState.singleAccountSyncing(
        data: {"address": event.account.address}));

    ApiDatabase database = Locator.instance<ApiDatabase>();
    Wallet wallet = database.walletStorage.currentWallet;

    Account account = await syncAccountVttsAndBalance(event.account);
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

  Future<PaginatedRequest<dynamic>> _getStatsByAddress(
      String address, String tab) async {
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
      if (result.runtimeType != AddressBlocks && result.data['error'] != null) {
        print('Error getting address blocks: ${result.data['error']}');
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
      if (result.data.runtimeType != AddressDataRequestsSolved) {
        print(
            'Error getting data requests solved for address: ${result.data.address}');
        return null;
      }
      return result.data as AddressDataRequestsSolved?;
    } catch (err) {
      print('Error getting data requests solved: $err');
      rethrow;
    }
  }

  //* TODO: add stake and unstake stats to account stats
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
        totalDrSolved: dataRequestsSolved?.dataRequestsSolved.length ?? 0);
  }

  Future<void> _updateDBStatsFromExplorer(
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

  Future<Account> _syncAccountVtts(Account account) async {
    try {
      AddressValueTransfers vtts = (await explorer.address(
              value: account.address, tab: 'value_transfers'))
          .data;
      WalletStorage walletStorage = database.walletStorage;
      for (int i = 0; i < vtts.addressValueTransfers.length; i++) {
        AddressValueTransferInfo newVtt = vtts.addressValueTransfers[i];
        ValueTransferInfo? vtt = walletStorage.getVtt(newVtt.hash);
        if (vtt != null) {
          if (vtt.status != TxStatusLabel.confirmed) {
            ValueTransferInfo? _vtt = await explorer.getVtt(newVtt.hash);
            if (_vtt != null) {
              walletStorage.setVtt(
                  database.walletStorage.currentWallet.id, _vtt);
              database.addOrUpdateVttInDB(_vtt);
            }
          }
        } else {
          ValueTransferInfo? _vtt = await explorer.getVtt(newVtt.hash);
          if (_vtt != null) {
            walletStorage.setVtt(database.walletStorage.currentWallet.id, _vtt);
            database.addOrUpdateVttInDB(_vtt);
          }
        }
      }
      account.vttHashes.clear();
      account.vttHashes.addAll(vtts.addressValueTransfers.map((e) => e.hash));
      return account;
    } catch (e) {
      print('Error updating vtts from explorer: $e');
      rethrow;
    }
  }

  Future<Account> _syncAccountUnstakes(Account account) async {
    try {
      //* TODO: use Unstakes instead of AddressBlocks
      /// retrieve all Block Hashes
      AddressBlocks? unstakes = (await explorer.address(
              value: account.address,
              //* TODO: get paginated Unstakes from unstake tab instead of AddressBlocks
              tab: 'blocks') as PaginatedRequest<AddressBlocks?>)
          .data;

      if (unstakes != null) {
        /// check if the list of transaction is already in the database
        //* TODO: use .unstakes from instead of .blocks
        for (int i = 0; i < unstakes.blocks.length; i++) {
          String unstakeHash = unstakes.blocks[i].hash;
          UnstakeEntry? unstakeEntry =
              database.walletStorage.getUnstake(unstakeHash);
          //* TODO: use UnstakeInfo from instead of BlocInfo
          BlockInfo unstakeInfo = unstakes.blocks.elementAt(i);

          if (unstakeEntry != null) {
            /// this mintEntry.status check for "confirmed" is in the local database
            if (unstakeEntry.status != TxStatusLabel.confirmed) {
              UnstakeEntry unstakeEntry =
                  await explorer.getUnstake(unstakeInfo);
              await account.addUnstake(unstakeEntry);
            }
          } else {
            UnstakeEntry unstakeEntry = await explorer.getUnstake(unstakeInfo);
            await account.addUnstake(unstakeEntry);
          }
        }

        account.unstakeHashes.clear();
        account.unstakeHashes
            .addAll(unstakes.blocks.map((unstake) => unstake.hash));
      }
      return account;
    } catch (e) {
      print('Error syncing mints $e');
      rethrow;
    }
  }

  Future<Account> _syncAccountStakes(Account account) async {
    try {
      //* TODO: use Stakes instead of AddressBlocks
      /// retrieve all Block Hashes
      AddressBlocks? stakes = (await explorer.address(
              value: account.address,
              //* TODO: get paginated Stakes from 'stake' tab instead of AddressBlocks
              tab: 'blocks') as PaginatedRequest<AddressBlocks?>)
          .data;

      if (stakes != null) {
        /// check if the list of transaction is already in the database
        //* TODO: use .stakes from instead of .blocks
        for (int i = 0; i < stakes.blocks.length; i++) {
          String stakeHash = stakes.blocks[i].hash;
          StakeEntry? stakeEntry = database.walletStorage.getStake(stakeHash);
          //* TODO: use StakeInfo from instead of BlocInfo
          BlockInfo stakeInfo = stakes.blocks.elementAt(i);

          if (stakeEntry != null) {
            /// this mintEntry.status check for "confirmed" is in the local database
            if (stakeEntry.status != TxStatusLabel.confirmed) {
              StakeEntry stakeEntry = await explorer.getStake(stakeInfo);
              await account.addStake(stakeEntry);
            }
          } else {
            StakeEntry stakeEntry = await explorer.getStake(stakeInfo);
            await account.addStake(stakeEntry);
          }
        }

        account.stakeHashes.clear();
        account.stakeHashes.addAll(stakes.blocks.map((stake) => stake.hash));
      }
      return account;
    } catch (e) {
      print('Error syncing mints $e');
      rethrow;
    }
  }

  Future<Account> _syncAccountMints(Account account) async {
    try {
      /// retrieve all Block Hashes
      AddressBlocks? addressBlocks = (await explorer.address(
              value: account.address,
              tab: 'blocks') as PaginatedRequest<AddressBlocks?>)
          .data;

      if (addressBlocks != null) {
        /// check if the list of transaction is already in the database
        for (int i = 0; i < addressBlocks.blocks.length; i++) {
          String blockHash = addressBlocks.blocks[i].hash;
          MintEntry? mintEntry = database.walletStorage.getMint(blockHash);
          BlockInfo blockInfo = addressBlocks.blocks.elementAt(i);

          if (mintEntry != null) {
            /// this mintEntry.status check for "confirmed" is in the local database
            if (mintEntry.status != TxStatusLabel.confirmed) {
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
            .addAll(addressBlocks.blocks.map((block) => block.hash));
      }
      return account;
    } catch (e) {
      print('Error syncing mints $e');
      rethrow;
    }
  }

  Future<Account> syncAccountVttsAndBalance(Account account) async {
    try {
      await _syncAccountVtts(account);
      await _syncAccountStakes(account);
      await _syncAccountUnstakes(account);
      if (account.keyType == KeyType.master) {
        await _syncAccountMints(account);
      }
      database.walletStorage.wallets[account.walletId]!.setAccount(account);
    } catch (e) {
      print('Error updating account vtts and balance $e');
      rethrow;
    }
    return account;
  }

  Future<void> syncWalletStorage(
      {required Map<String, List<Utxo>> utxos, required Wallet wallet}) async {
    for (int addressIndex = 0; addressIndex < utxos.length; addressIndex++) {
      String address = utxos.keys.toList()[addressIndex];
      List<Utxo> utxoList = utxos[address] ?? [];
      Account? account = wallet.accountByAddress(address);
      if (account != null && !account.sameUtxoList(utxoList)) {
        if (utxoList.isNotEmpty) {
          account.updateUtxos(utxoList);
          account = await syncAccountVttsAndBalance(account);
        } else {
          account.utxos.clear();
        }
        wallet.updateAccount(
          index: account.index,
          keyType: account.keyType,
          account: account,
        );
      }
    }
  }

  _updateWalletList({required WalletStorage storage, required Wallet wallet}) {
    storage.wallets[wallet.id] = wallet;
  }

  Future<WalletStorage> syncWalletRoutine(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {
    /// get current wallet
    ApiDatabase database = Locator.instance<ApiDatabase>();
    WalletStorage storage = database.walletStorage;
    Wallet wallet = storage.currentWallet;

    /// get a list of any pending transactions
    List<ValueTransferInfo> unconfirmedVtts = wallet.unconfirmedTransactions();
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
          await syncWalletStorage(utxos: _utxos, wallet: wallet);
          _updateWalletList(storage: storage, wallet: wallet);
        }
      } catch (err) {
        print('Error updating UTXOs $err');
        rethrow;
      }
    } else if (wallet.walletType == WalletType.single) {
      List<Utxo> utxoList = await Locator.instance<ApiExplorer>()
          .utxos(address: wallet.masterAccount!.address);

      await _updateDBStatsFromExplorer(
          currentWallet: wallet, database: database);
      await syncWalletStorage(
          utxos: {wallet.masterAccount!.address: utxoList}, wallet: wallet);
      _updateWalletList(storage: storage, wallet: wallet);
    }

    for (int i = 0; i < unconfirmedVtts.length; i++) {
      ValueTransferInfo _vtt = unconfirmedVtts[i];
      try {
        ValueTransferInfo? vtt = await explorer.getVtt(_vtt.txnHash);
        if (vtt != null && _vtt.status != vtt.status) {
          await database.updateVtt(wallet.id, vtt);
        }
      } catch (e) {
        /// If the getVtt method returns null we enter this catch
        /// and the vtt has an unknown hash

        /// check the inputs for accounts in the wallet and remove the vtt
        for (int i = 0; i < _vtt.inputAddresses.length; i++) {
          Account? account = wallet.accountByAddress(_vtt.inputAddresses[i]);
          if (account != null) {
            await account.deleteVtt(_vtt);
          }
        }

        /// check the outputs for accounts in the wallet and remove the vtt
        for (int i = 0; i < _vtt.outputAddresses.length; i++) {
          Account? account = wallet.accountByAddress(_vtt.outputAddresses[i]);
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
    return storage;
  }
}
