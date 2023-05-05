import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
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
    try {
      // TODO: check if the explorer is up
      await syncWalletRoutine(event, emit);
    } catch (e) {
      print('Error syncing the Wallet $e');
      rethrow;
    }
  }

  Future<void> syncWalletRoutine(
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
    for (int i = 0; i < addressChunks.length; i++) {
      Map<String, List<Utxo>> _utxos = await Locator.instance<ApiExplorer>()
          .utxosMulti(addressList: addressChunks[i]);

      /// loop over the explorer response
      /// which is Map<String, List<Utxo>> key = address
      Map<String, Account> updatedAccounts = {};

      for (int addressIndex = 0; addressIndex < _utxos.length; addressIndex++) {
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
          wallet.updateAccount(
              index: account.index, keyType: account.keyType, account: account);
        }
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
      } catch (e) {}
    }
    emit(ExplorerState.synced(database.walletStorage));
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
      await account.setBalance();
      database.walletStorage.wallets[account.walletId]!.setAccount(account);
    } catch (e) {
      print('Error updating account vtts and balance $e');
    }
    return account;
  }
}
