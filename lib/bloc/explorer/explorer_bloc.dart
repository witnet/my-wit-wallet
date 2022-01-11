import 'package:bloc/bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/bloc/transactions/value_transfer/create_vtt_bloc.dart';
import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/database_service.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

abstract class ExplorerEvent {}

class HashQueryEvent extends ExplorerEvent {
  final String value;
  final bool utxos;
  HashQueryEvent({required this.value, required this.utxos});
}

class HomeQueryEvent extends ExplorerEvent {}

class NetworkQueryEvent extends ExplorerEvent {}

class StatusQueryEvent extends ExplorerEvent {}

class PendingQueryEvent extends ExplorerEvent {}

class ReputationQueryEvent extends ExplorerEvent {}

class RichListQueryEvent extends ExplorerEvent {}

class UtxoQueryEvent extends ExplorerEvent {
  final Account account;

  UtxoQueryEvent(this.account);
}

class AddressQueryEvent extends ExplorerEvent {
  String address;
  String tab;
  AddressQueryEvent(this.address, this.tab);
}

class SyncWalletEvent extends ExplorerEvent {}

class BlockchainQueryEvent extends ExplorerEvent {}

class TapiQueryEvent extends ExplorerEvent {}

class VTTransactionPostEvent extends ExplorerEvent {
  final VTTransaction vtTransaction;
  VTTransactionPostEvent(this.vtTransaction);
}

abstract class ExplorerState {}

class DataLoadingState extends ExplorerState {}

class DataLoadedState extends ExplorerState {
  Map<String, dynamic> data;
  DataLoadedState({required this.data});
}

class SyncedState extends ExplorerState {
  final DbWallet dbWallet;
  SyncedState(this.dbWallet);
}

class ExplorerErrorState extends ExplorerState {}

class ReadyState extends ExplorerState {
  Status? status;
}

class BlocExplorer extends Bloc<ExplorerEvent, ExplorerState> {
  BlocExplorer(ExplorerState initialState) : super(initialState);
  ExplorerState get initialState => ReadyState();
  @override
  Stream<ExplorerState> mapEventToState(ExplorerEvent event) async* {
    try {
      switch (event.runtimeType) {
        case HashQueryEvent:
          event as HashQueryEvent;
          try {
            yield DataLoadingState();
            // load data
            var resp = await Locator.instance
                .get<ApiExplorer>()
                .hash(event.value, event.utxos);
            yield DataLoadedState(data: {'data': resp});
          } on ExplorerException {
            yield ExplorerErrorState();
            rethrow;
          }
          break;
        case StatusQueryEvent:
          try {
            yield DataLoadingState();
            var resp = await Locator.instance.get<ApiExplorer>().getStatus();

            yield DataLoadedState(data: resp.jsonMap());
          } on ExplorerException {
            yield ExplorerErrorState();
            rethrow;
          }
          break;
        case AddressQueryEvent:
          event as AddressQueryEvent;
          try {
            yield DataLoadingState();
            var resp = await Locator.instance
                .get<ApiExplorer>()
                .address(value: event.address, tab: event.tab);
            yield DataLoadedState(data: resp.jsonMap());
          } on ExplorerException {
            yield ExplorerErrorState();
            rethrow;
          }
          break;

        case SyncWalletEvent:
          yield DataLoadingState();
          try {
            /// check explorer status
            bool explorerReady = true;

            if(explorerReady){
              List<String> addressList = [];

              /// get the current state of the wallet from the database
              DbWallet dbWallet =
              await Locator.instance<ApiDatabase>().loadWallet();

              /// verify gap limit

              /// external chain
              Map<String, Account> _extAccounts = {};
              int externalGap = 0;
              for(int i = 1; i < dbWallet.externalAccounts.length-1; i ++ ){

                addressList.add(dbWallet.externalAccounts[i]!.address);
                if(dbWallet.externalAccounts[i]!.vttHashes.length>0){
                  externalGap = 0;
                } else {
                  externalGap += 1;
                }
              }


              /// if the gap limit is not maintained then generate additional accounts
              ///
              int lastExternalIndex = dbWallet.externalAccounts.length;
              while(externalGap <= EXTERNAL_GAP_LIMIT){
                Account account = await dbWallet.generateKey(index: lastExternalIndex, keyType: KeyType.external);
                lastExternalIndex+=1;
                externalGap += 1;
              }


              int internalGap = 0;

              for(int i = 0; i < dbWallet.internalAccounts.length; i ++){
                final Account currentAccount = dbWallet.internalAccounts[i]!;
                if(currentAccount.vttHashes.length > 0){
                  internalGap = 0;
                } else {
                  internalGap += 1;
                }
              }
              int lastInternalIndex = dbWallet.internalAccounts.length;
              while(internalGap <= INTERNAL_GAP_LIMIT){
                Account account = await dbWallet.generateKey(index: lastInternalIndex, keyType: KeyType.internal);
                lastInternalIndex+=1;
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
                Map<String, List<Utxo>> _utxos =
                await Locator.instance<ApiExplorer>()
                    .utxosMulti(addresses: addressChunks[i]);

                /// loop over the explorer response
                /// which is Map<String, List<Utxo>> key = address
                for(int addressIndex = 0; addressIndex < _utxos.length; addressIndex ++){
                  String address = _utxos.keys.toList()[addressIndex];
                  List<Utxo> utxoList = _utxos[address]!;

                  /// update the external xprv utxo list and balance
                  if (_extAccounts.containsKey(address)) {

                    /// check if the UTXO set is different
                    int currentLength = _extAccounts[address]!.utxos.length;
                    int newLength = utxoList.length;

                    /// check if the UTXO set is different
                    if(currentLength != newLength){
                      if (utxoList.isNotEmpty) {
                        _extAccounts[address]!.utxos.clear();
                        _extAccounts[address]!.utxos.addAll(utxoList);
                      } else {
                        _extAccounts[address]!.utxos.clear();
                      }
                      AddressValueTransfers vtts = await Locator.instance
                          .get<ApiExplorer>().address(value: address, tab: 'value_transfers');
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
                          .get<ApiExplorer>().address(value: address, tab: 'value_transfers');
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
                dbWallet.externalAccounts[int.parse(account.path.split('/').last)]
                = account;
              });

              /// restructure  the accounts map to store in the database
              Map<int, Account> _intAccntsDb = {};
              _intAccounts.forEach((key, account) {
                dbWallet.internalAccounts[int.parse(account.path.split('/').last)]
                = account;
              });

              /// save the synced data to the local database (encrypts salsa20)
              await Locator.instance<ApiDatabase>().saveDbWallet(dbWallet);

              yield SyncedState(dbWallet);
            }
          } catch (e) {
            yield ExplorerErrorState();
          }
          break;
        case VTTransactionPostEvent:
          yield DataLoadingState();
          event as VTTransactionPostEvent;
          try {
            var resp = await Locator.instance
                .get<ApiExplorer>()
                .sendVtTransaction(event.vtTransaction);
          } catch (e) {}
          break;
        case UtxoQueryEvent:
          event as UtxoQueryEvent;
          yield DataLoadingState();
          try {
            var resp = await Locator.instance
                .get<ApiExplorer>()
                .utxos(address: event.account.address);
            var utxoList = {};
            resp.forEach((element) {
              utxoList[element.outputPointer.transactionId] = element;
            });

            yield DataLoadedState(data: {'utxos': utxoList});
          } catch (e) {
            rethrow;
          }
          break;
        default:
      }
    } catch (e) {
      rethrow;
    }
  }
}
