import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:my_wit_wallet/util/utxo_list_to_string.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
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

  Future<void> _syncWalletEvent(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {
    try {
      add(DataLoadingEvent(ExplorerStatus.dataloading));
      add(DataLoadedEvent(
          ExplorerStatus.dataloaded, await syncWalletRoutine(event, emit)));
    } catch (e) {
      setError(e);
    }
    // Create a periodic stream for syncing the wallet
    syncWalletStream = Stream.periodic(Duration(seconds: 30), (_) {
      add(DataLoadingEvent(ExplorerStatus.dataloading));
      return syncWalletRoutine(event, emit);
    }).asyncMap((event) async => await event);
    if (syncWalletSubscription != null) syncWalletSubscription!.cancel();
    syncWalletSubscription = syncWalletStream.listen((event) {
      add(DataLoadedEvent(ExplorerStatus.dataloaded, event));
    }, onError: setError, cancelOnError: false);
  }

  void setError(error) {
    print('Error syncing the wallet $error');
    add(SyncErrorEvent(ExplorerStatus.error));
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
          Map<String, List<Utxo>> _utxos = await Locator.instance<ApiExplorer>()
              .utxosMulti(addressList: addressChunks[i]);

          /// loop over the explorer response
          /// which is Map<String, List<Utxo>> key = address
          Map<String, Account> updatedAccounts = {};

          for (int addressIndex = 0;
              addressIndex < _utxos.length;
              addressIndex++) {
            String address = _utxos.keys.toList()[addressIndex];
            List<Utxo> utxoList = _utxos[address]!;

            Account account = wallet.accountByAddress(address)!;

            if (!isTheSameList(account, utxoList)) {
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
        print('Error getting UTXOs from the explorer $err');
        rethrow;
      }
    } else if (wallet.walletType == WalletType.single) {
      List<Utxo> utxoList = await Locator.instance<ApiExplorer>()
          .utxos(address: wallet.masterAccount!.address);
      Account account = wallet.masterAccount!;

      if (!isTheSameList(wallet.masterAccount!, utxoList)) {
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
        var vtt = await Locator.instance.get<ApiExplorer>().hash(_vtt.txnHash);
        if (vtt.jsonMap()['status'] == 'unknown hash') {
          vtt = _vtt;
          ValueTransferInfo unknownTransaction = _vtt;
          unknownTransaction.status = 'unknown hash';
          await database.updateVtt(wallet.id, unknownTransaction);
        }
      }
    }
    await database.loadWalletsDatabase();
    await database.updateCurrentWallet(
        currentWalletId: wallet.id,
        isHdWallet: wallet.walletType == WalletType.hd);
    return database.walletStorage;
  }

  bool isTheSameList(Account account, List<Utxo> utxoList) {
    int currentLength = account.utxos.length;
    int newLength = utxoList.length;
    bool isSameList = true;
    if (currentLength == newLength) {
      utxoList.forEach((element) {
        bool containsUtxo =
            rawJsonUtxosList(account.utxos).contains(element.toRawJson());
        if (!containsUtxo) {
          isSameList = false;
        }
      });
    } else {
      isSameList = false;
    }
    return isSameList;
  }

  Future<Account> _syncMints(Account account) async {
    try {
      /// retrieve all Block Hashes
      ApiExplorer explorer = Locator.instance.get<ApiExplorer>();
      final addressBlocks = await explorer.address(
          value: account.address, tab: 'blocks') as AddressBlocks;

      /// check if the list of transaction is already in the database
      for (int i = 0; i < addressBlocks.blocks.length; i++) {
        String blockHash = addressBlocks.blocks[i].blockID;
        ApiDatabase database = Locator.instance.get<ApiDatabase>();
        MintEntry? mintEntry = database.walletStorage.getMint(blockHash);
        if (mintEntry != null && !account.mintHashes.contains(blockHash)) {
          BlockInfo blockInfo = addressBlocks.blocks.elementAt(i);

          MintEntry mintEntry = await explorer.getMint(blockInfo);
          account.mintHashes.add(mintEntry.blockHash);
          account.mints.add(mintEntry);
          await database.addMint(mintEntry);
        }
      }
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
        if (vtt != null && !account.vttHashes.contains(transactionId)) {
          if (vtt.status != "confirmed") {
            ValueTransferInfo vtt =
                await Locator.instance.get<ApiExplorer>().getVtt(transactionId);
            account.addVtt(vtt);

            await database.addVtt(vtt);
            await database.updateAccount(account);
          }
        } else {
          ValueTransferInfo vtt =
              await Locator.instance.get<ApiExplorer>().getVtt(transactionId);
          account.addVtt(vtt);
          await database.addVtt(vtt);
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
