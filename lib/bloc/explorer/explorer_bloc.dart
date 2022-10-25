import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'package:witnet_wallet/util/storage/database/account.dart';
import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

part 'explorer_event.dart';
part 'explorer_state.dart';

enum ExplorerStatus { unknown, dataloading, dataloaded, error, ready }

class ExplorerBloc extends Bloc<ExplorerEvent, ExplorerState> {
  ExplorerBloc(initialState) : super(initialState) {
    on<HashQueryEvent>(_hashQueryEvent);
    on<StatusQueryEvent>(_statusQueryEvent);
    on<AddressQueryEvent>(_addressQueryEvent);
    on<VTTransactionPostEvent>(_vtTransactionPostEvent);
    on<UtxoQueryEvent>(_utxoQueryEvent);
    on<SyncWalletEvent>(_syncWalletEvent);
  }

  static ExplorerState get initialState => ExplorerState.ready();

  Future<void> _hashQueryEvent(
      HashQueryEvent event, Emitter<ExplorerState> emit) async {
    var resp = await Locator.instance
        .get<ApiExplorer>()
        .hash(event.value, event.utxos);
    return emit(
        ExplorerState.dataLoaded(data: resp, query: ExplorerQuery.hash));
  }

  Future<void> _statusQueryEvent(
      StatusQueryEvent event, Emitter<ExplorerState> emit) async {
    var resp = await Locator.instance.get<ApiExplorer>().getStatus();
    return emit(ExplorerState.dataLoaded(
        data: resp.jsonMap(), query: ExplorerQuery.status));
  }

  Future<void> _addressQueryEvent(
      AddressQueryEvent event, Emitter<ExplorerState> emit) async {
    var resp = await Locator.instance
        .get<ApiExplorer>()
        .address(value: event.address, tab: event.tab);
    return emit(ExplorerState.dataLoaded(
        data: resp.jsonMap(), query: ExplorerQuery.address));
  }

  Future<void> _vtTransactionPostEvent(
      VTTransactionPostEvent event, Emitter<ExplorerState> emit) async {
    var resp = await Locator.instance
        .get<ApiExplorer>()
        .sendVtTransaction(event.vtTransaction);

    return emit(
        ExplorerState.dataLoaded(query: ExplorerQuery.sendVtt, data: resp));
  }

  Future<void> _utxoQueryEvent(
      UtxoQueryEvent event, Emitter<ExplorerState> emit) async {
    var resp = await Locator.instance
        .get<ApiExplorer>()
        .utxos(address: event.account.address);
    var utxoList = {};
    resp.forEach((element) {
      utxoList[element.outputPointer.transactionId] = element;
    });

    return emit(ExplorerState.dataLoaded(
        query: ExplorerQuery.utxos, data: {'utxos': utxoList}));
  }

  Future<void> _syncWalletEvent(
      SyncWalletEvent event, Emitter<ExplorerState> emit) async {

    /// get the current state of the wallet from the database
    WalletStorage walletStorage =
        await Locator.instance<ApiDatabase>().loadWalletsDatabase();
    try {
      /// for each wallet
      for (int n = 0; n < walletStorage.wallets.length; n++) {
        Wallet wallet = walletStorage.wallets[n]!;

        await syncWalletRoutine(wallet);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> syncWalletRoutine(Wallet dbWallet) async {
    /// verify gap limit
    /// external chain

    ApiDatabase db = Locator.instance<ApiDatabase>();

    Map<String, Account> _extAccounts = {};
    List<String> addressList = [];
    int externalGap = 0;
    for (int i = 1; i < dbWallet.externalAccounts.length - 1; i++) {
      addressList.add(dbWallet.externalAccounts[i]!.address);
      if (dbWallet.externalAccounts[i]!.vttHashes.length > 0) {
        externalGap = 0;
      } else {
        externalGap += 1;
      }
    }

    /// if the gap limit is not maintained then generate additional accounts
    ///
    int lastExternalIndex = dbWallet.externalAccounts.length;
    while (externalGap <= EXTERNAL_GAP_LIMIT) {
      await dbWallet.generateKey(
        index: lastExternalIndex,
        keyType: KeyType.external,
      );
      lastExternalIndex += 1;
      externalGap += 1;
    }

    int internalGap = 0;

    for (int i = 0; i < dbWallet.internalAccounts.length; i++) {
      final Account currentAccount = dbWallet.internalAccounts[i]!;
      if (currentAccount.vttHashes.length > 0) {
        internalGap = 0;
      } else {
        internalGap += 1;
      }
    }
    int lastInternalIndex = dbWallet.internalAccounts.length;
    while (internalGap <= INTERNAL_GAP_LIMIT) {
      await dbWallet.generateKey(
          index: lastInternalIndex, keyType: KeyType.internal);
      lastInternalIndex += 1;
      internalGap += 1;
    }

    dbWallet.externalAccounts.forEach((index, account) {
      addressList.add(account.address);
      _extAccounts[account.address] = account;
    });

    /// internal chain
    Map<String, Account> _intAccounts = {};
    dbWallet.internalAccounts.forEach((index, account) {
      addressList.add(account.address);
      _intAccounts[account.address] = account;
    });

    /// address limit is the limit of the explorer API
    int addressLimit = 10;
    List<List<String>> addressChunks = [];

    /// break the address list into chunks of 10 addresses
    for (int i = 0; i < addressList.length; i += addressLimit) {
      int end = (i + addressLimit < addressList.length)
          ? i + addressLimit
          : addressList.length;
      addressChunks.add([addressList.sublist(i, end).join(',')]);
    }

    /// get the UTXOs from the explorer
    for (int i = 0; i < addressChunks.length; i++) {
      Map<String, List<Utxo>> _utxos = await Locator.instance<ApiExplorer>()
          .utxosMulti(addresses: addressChunks[i]);

      /// loop over the explorer response
      /// which is Map<String, List<Utxo>> key = address
      for (int addressIndex = 0; addressIndex < _utxos.length; addressIndex++) {
        String address = _utxos.keys.toList()[addressIndex];
        List<Utxo> utxoList = _utxos[address]!;

        /// update the external xprv utxo list and balance
        if (_extAccounts.containsKey(address)) {
          /// check if the UTXO set is different
          int currentLength = _extAccounts[address]!.utxos.length;
          int newLength = utxoList.length;

          /// check if the UTXO set is different
          if (currentLength != newLength) {
            if (utxoList.isNotEmpty) {
              _extAccounts[address]!.utxos.clear();
              _extAccounts[address]!.utxos.addAll(utxoList);
            } else {
              _extAccounts[address]!.utxos.clear();
            }
            AddressValueTransfers vtts = await Locator.instance
                .get<ApiExplorer>()
                .address(value: address, tab: 'value_transfers');

            await Future.delayed(Duration(milliseconds: EXPLORER_DELAY_MS));
            _extAccounts[address]!.vttHashes.clear();
            _extAccounts[address]!.vttHashes.addAll(vtts.transactionHashes);
            _extAccounts[address]!.setBalance();
          }
        }

        /// update the internal xprv utxo list and balance
        if (_intAccounts.containsKey(address)) {
          int currentLength = _intAccounts[address]!.utxos.length;
          int newLength = utxoList.length;

          /// check if the UTXO set is different
          if (currentLength != newLength) {
            if (utxoList.isNotEmpty) {
              _intAccounts[address]!.utxos.clear();
              _intAccounts[address]!.utxos.addAll(utxoList);
            } else {
              _intAccounts[address]!.utxos.clear();
            }
            AddressValueTransfers vtts = await Locator.instance
                .get<ApiExplorer>()
                .address(value: address, tab: 'value_transfers');
            await Future.delayed(Duration(milliseconds: EXPLORER_DELAY_MS));
            _intAccounts[address]!.vttHashes.clear();
            _intAccounts[address]!.vttHashes.addAll(vtts.transactionHashes);
            _intAccounts[address]!.setBalance();
          }
        }
      }

      /// pause to not overload the explorer
      await Future.delayed(Duration(milliseconds: EXPLORER_DELAY_MS));
    }

    /// restructure  the accounts map to store in the database
    Map<int, Account> _extAccntsDb = {};
    _extAccounts.forEach((key, account) {
      dbWallet.externalAccounts[int.parse(account.path.split('/').last)] =
          account;
    });

    /// restructure  the accounts map to store in the database
    Map<int, Account> _intAccntsDb = {};
    _intAccounts.forEach((key, account) {
      dbWallet.internalAccounts[int.parse(account.path.split('/').last)] =
          account;
    });


    for(int i = 0; i < _extAccntsDb.length; i ++) {
      await db.updateAccount(_extAccntsDb.values.elementAt(i));
    }
    for(int i = 0; i < _intAccntsDb.length; i ++) {
      await db.updateAccount(_intAccntsDb.values.elementAt(i));
    }
    return emit(ExplorerState.synced(await db.loadWalletsDatabase()));
  }
}
