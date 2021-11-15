import 'package:bloc/bloc.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/bloc/explorer/api_explorer.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
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

class ExplorerErrorState extends ExplorerState {}

class ReadyState extends ExplorerState {}

class BlocExplorer extends Bloc<ExplorerEvent, ExplorerState> {
  BlocExplorer(ExplorerState initialState) : super(initialState);
  ExplorerState get initialState => ReadyState();
  @override
  Stream<ExplorerState> mapEventToState(ExplorerEvent event) async* {
    print(event.runtimeType);
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
            var resp = await Locator.instance.get<ApiExplorer>().status();
            print(resp.toRawJson());
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
            Status status = await Locator.instance<ApiExplorer>().status();
            var internalAccounts = await Locator.instance<ApiDatabase>()
                    .readDatabaseRecord(key: 'internal_accounts', type: Map)
                as Map<String, Object?>;
            var externalAccounts = await Locator.instance<ApiDatabase>()
                    .readDatabaseRecord(key: 'external_accounts', type: Map)
                as Map<String, Object?>;

            /// external chain
            Map<String, Account> _extAccounts = {};
            externalAccounts.forEach((key, value) {
              print(value);
              _extAccounts[key] =
                  Account.fromJson(value as Map<String, dynamic>);
            });

            List<Account> extAccounts = _extAccounts.values.toList();
            for (int i = 0; i < extAccounts.length; i++) {
              Account _account = extAccounts[i];
              if (_account.lastSynced == -1) {
                List<Utxo> _utxos = await Locator.instance<ApiExplorer>()
                    .utxos(address: _account.address);
                print(_utxos);
                await Future.delayed(Duration(milliseconds: 150));
                _account.utxos = _utxos;
                _account.lastSynced = status.nodePool.currentEpoch;
                _account.setBalance();
                _extAccounts[_account.address] = _account;
              }
            }
            _extAccounts.forEach((key, value) {
              print(
                  '$key, ${value.address} ${value.valueTransfers.length} ${value.utxos.length} ${value.lastSynced}');
            });

            Map<String, dynamic> _extAccntsDb = {};
            _extAccounts.forEach((key, value) {
              _extAccntsDb[key] = value.jsonMap();
            });

            await Locator.instance<ApiDatabase>().writeDatabaseRecord(
                key: 'external_accounts', value: _extAccntsDb);

            /// internal chain
            Map<String, Account> _intAccounts = {};

            internalAccounts.forEach((key, value) {
              print(value);
              _intAccounts[key] =
                  Account.fromJson(value as Map<String, dynamic>);
            });

            List<Account> intAccounts = _intAccounts.values.toList();

            for (int i = 0; i < extAccounts.length; i++) {
              Account _account = extAccounts[i];
              if (_account.lastSynced == -1) {
                List<Utxo> _utxos = await Locator.instance<ApiExplorer>()
                    .utxos(address: _account.address);
                print(_utxos);
                await Future.delayed(Duration(milliseconds: 150));
                _account.utxos = _utxos;
                _account.lastSynced = status.nodePool.currentEpoch;
                _account.setBalance();
                _intAccounts[_account.address] = _account;
              }
            }

            _intAccounts.forEach((key, value) {
              print(
                  '$key, ${value.address} ${value.valueTransfers.length} ${value.utxos.length} ${value.lastSynced}');
            });

            Map<String, dynamic> _intAccntsDb = {};
            _intAccounts.forEach((key, value) {
              _intAccntsDb[key] = value.jsonMap();
            });
            await Locator.instance<ApiDatabase>()
                .writeDatabaseRecord(key: 'internal_keys', value: _intAccntsDb);

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
