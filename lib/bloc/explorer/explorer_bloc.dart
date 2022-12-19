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
import 'package:witnet_wallet/util/utxo_list_to_string.dart';

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
    try {
      // TODO: check if the explorer is up
      await syncWalletRoutine(event.currentWallet);
    } catch (e) {
      print('Error syncing the Wallet $e');
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
    dbWallet.externalAccounts.forEach((key, value) {
      addressList.add(value.address);
      if (value.vttHashes.length > 0) {
        externalGap = 0;
      } else {
        externalGap += 1;
      }
    });

    /// if the gap limit is not maintained then generate additional accounts
    ///
    int lastExternalIndex = dbWallet.externalAccounts.length;
    while (externalGap < EXTERNAL_GAP_LIMIT) {
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
    while (internalGap < INTERNAL_GAP_LIMIT) {
      await dbWallet.generateKey(
          index: lastInternalIndex, keyType: KeyType.internal);
      lastInternalIndex += 1;
      internalGap += 1;
    }

    dbWallet.externalAccounts.forEach((index, account) {
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
          Account externalAccount = _extAccounts[address]!;

          /// check if the UTXO set is different
          if (!isTheSameList(externalAccount, utxoList)) {
            if (utxoList.isNotEmpty) {
              externalAccount.utxos.clear();
              externalAccount.utxos.addAll(utxoList);
            } else {
              externalAccount.utxos.clear();
            }
            await updateAccountVttsAndBalance(externalAccount);
          }
        }

        /// update the internal xprv utxo list and balance
        if (_intAccounts.containsKey(address)) {
          Account internalAccount = _intAccounts[address]!;

          /// check if the UTXO set is different
          if (!isTheSameList(internalAccount, utxoList)) {
            if (utxoList.isNotEmpty) {
              internalAccount.utxos.clear();
              internalAccount.utxos.addAll(utxoList);
            } else {
              internalAccount.utxos.clear();
            }
            await updateAccountVttsAndBalance(_intAccounts[address]!);
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
      _extAccntsDb[int.parse(account.path.split('/').last)] = account;
    });

    /// restructure  the accounts map to store in the database
    Map<int, Account> _intAccntsDb = {};
    _intAccounts.forEach((key, account) {
      dbWallet.internalAccounts[int.parse(account.path.split('/').last)] =
          account;
      _intAccntsDb[int.parse(account.path.split('/').last)] = account;
    });

    await addVtt(_extAccntsDb, db);
    await addVtt(_intAccntsDb, db);

    return emit(ExplorerState.synced(await db.loadWalletsDatabase()));
  }
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

Future updateAccountVttsAndBalance(Account account) async {
  try {
    AddressValueTransfers vtts = await Locator.instance
        .get<ApiExplorer>()
        .address(value: account.address, tab: 'value_transfers');

    await Future.delayed(Duration(milliseconds: EXPLORER_DELAY_MS));
    account.vttHashes.clear();
    account.vttHashes.addAll(vtts.transactionHashes);
    account.setBalance();
  } catch (e) {
    print('Error updating account vtts and balance $e');
  }
}

Future addVtt(Map<int, Account> accountsDb, ApiDatabase db) async {
  for (int i = 0; i < accountsDb.keys.length; i++) {
    Account account = accountsDb.values.elementAt(i);

    for (int j = 0; j < account.vttHashes.length; j++) {
      try {
        String _hash = account.vttHashes.elementAt(j);
        await Future.delayed(Duration(milliseconds: EXPLORER_DELAY_MS));

        var result = await Locator.instance.get<ApiExplorer>().hash(_hash);
        ValueTransferInfo valueTransferInfo = result as ValueTransferInfo;
        await db.addVtt(valueTransferInfo);
      } catch (e) {
        print('Error adding vtt to database $e');
      }
    }
    await db.updateAccount(account);
  }
}
