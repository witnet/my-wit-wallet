import 'package:bloc/bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';

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
            // check explorer status
            Status status = await Locator.instance<ApiExplorer>().getStatus();

            print('status.databaseMessage: ${status.databaseMessage}');


            List<String> addressList = [];
            DbWallet dbWallet = await Locator.instance<ApiDatabase>().loadWallet();
            /// external chain
            ///
            Map<String, Account> _extAccounts = {};

            dbWallet.externalAccounts.forEach((index, account) {

              print(account.address);
              addressList.add(account.address);
              _extAccounts[account.address] = account;
            });
            /// internal chain
            Map<String, Account> _intAccounts = {};
            dbWallet.internalAccounts.forEach((index, account) {

              addressList.add(account.address);
              _intAccounts[account.address] = account;
            });

            print('getting utxos for ${addressList.length} accounts.');
            print(addressList);

            int addressLimit = 10;
            List<List<String>> addressChunks = [];

            for (int i = 0; i < addressList.length; i += addressLimit) {
              int end = (i + addressLimit < addressList.length)
                  ? i + addressLimit
                  : addressList.length;
              addressChunks.add([addressList.sublist(i, end).join(',')]);
            }

            for(int i = 0; i < addressChunks.length; i++){

            Map<String, List<Utxo>> _utxos = await Locator.instance<ApiExplorer>().utxosMulti(addresses: addressChunks[i]);
            print(_utxos);
            for(int j = 0; j < _utxos.keys.length; j ++){
              String currentAddress = _utxos.keys.elementAt(j);
              print('----- $currentAddress');
            }
            _utxos.forEach((key, utxoList) {
              print('$key ----');
              if(_extAccounts.containsKey(key)){
                if(utxoList.isNotEmpty){
                  _extAccounts[key]!.utxos.clear();
                  _extAccounts[key]!.utxos = utxoList;
                  _extAccounts[key]!.setBalance();
                } else {
                  _extAccounts[key]!.utxos.clear();
                }
              }
              if(_intAccounts.containsKey(key)){
                if(utxoList.isNotEmpty){
                  _intAccounts[key]!.utxos.clear();
                  _intAccounts[key]!.utxos = utxoList;
                  _intAccounts[key]!.setBalance();
                } else {
                  _intAccounts[key]!.utxos.clear();
                }
              }
            });
            await Future.delayed(Duration(milliseconds: 300));
            }



            _extAccounts.forEach((key, value) {
              print('$key ${value.utxos} ${value.path}');
            });

            dbWallet.internalAccounts.forEach((index, account) {
              if(_extAccounts.containsKey(account.address)){
                if(_extAccounts[account.address]!.utxos.length > 0){

                print('${_extAccounts[account.address]!.utxos.map((e) => e.toRawJson())}');
                }
              }

            });


            Map<int, Account> _extAccntsDb = {};
            _extAccounts.forEach((key, value) {
              int index = int.parse(value.path.split('/').last);
              _extAccntsDb[index] = value;
              print('${dbWallet.externalAccounts[index]!.utxos.length} ${value.utxos.length}');
              dbWallet.externalAccounts[index] =value;
            });
            Map<int, Account> _intAccntsDb = {};
            _intAccounts.forEach((key, value) {
              dbWallet.internalAccounts[int.parse(value.path.split('/').last)] = value;

              _intAccntsDb[int.parse(value.path.split('/').last)] = value;
            });
            dbWallet.internalAccounts.forEach((key, value) {

            });
            dbWallet.externalAccounts = _extAccntsDb;
            dbWallet.externalAccounts.forEach((key, value) {
              print('${value.path} ${value.utxos.length}');

            });
            dbWallet.internalAccounts.forEach((key, value) {
              print('${value.path} ${value.utxos.length}');

            });
            //await Locator.instance<ApiDatabase>().saveDbWallet(dbWallet);

            ///
            ///
            yield ReadyState();
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
            print(resp);
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
