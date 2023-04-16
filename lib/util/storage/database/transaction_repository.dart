import 'package:sembast/sembast.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

abstract class _TransactionRepository {
  Future<bool> insertTransaction(
    dynamic transaction,
    DatabaseClient databaseClient,
  );

  Future<bool> updateTransaction(
    dynamic transaction,
    DatabaseClient databaseClient,
  );

  Future<bool> deleteTransaction(
    String transactionId,
    DatabaseClient databaseClient,
  );

  Future<List<dynamic>> getAllTransactions(DatabaseClient databaseClient);
}

class VttRepository extends _TransactionRepository {
  final StoreRef _store = stringMapStoreFactory.store("value_transfers");

  @override
  Future<bool> deleteTransaction(
      String transactionId, DatabaseClient databaseClient) async {
    try {
      await _store.record(transactionId).delete(databaseClient);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ValueTransferInfo>> getAllTransactions(
      DatabaseClient databaseClient) async {
    final snapshots = await _store.find(databaseClient);
    List<ValueTransferInfo> transactions = snapshots
        .map((snapshot) => ValueTransferInfo.fromDbJson(snapshot.value as Map<String, dynamic>))
        .toList(growable: false);
    return transactions;
  }

  @override
  Future<bool> insertTransaction(
      transaction, DatabaseClient databaseClient) async {
    try {
      assert(transaction.runtimeType == ValueTransferInfo);
      await _store
          .record(transaction.txnHash)
          .add(databaseClient, transaction.jsonMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateTransaction(
      transaction, DatabaseClient databaseClient) async {
    try {
      assert(transaction.runtimeType == ValueTransferInfo);
      await _store
          .record(transaction.txnHash)
          .update(databaseClient, transaction.jsonMap());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}

class DataRequestRepository extends _TransactionRepository {
  final StoreRef _store = stringMapStoreFactory.store("data_requests");

  @override
  Future<bool> deleteTransaction(
    String transactionId,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store.record(transactionId).delete(databaseClient);
    } catch (e) {
      return false;
    }
    return true;
  }

  @override
  Future<List> getAllTransactions(DatabaseClient databaseClient) async {
    final List<RecordSnapshot<dynamic, dynamic>> snapshots =
        await _store.find(databaseClient);

    List<DRTransaction> wallets = snapshots
        .map((snapshot) => DRTransaction.fromJson(snapshot.value))
        .toList(growable: false);
    return wallets;
  }

  @override
  Future<bool> insertTransaction(
    transaction,
    DatabaseClient databaseClient,
  ) async {
    try {
      assert(transaction.runtimeType == DRTransaction);
      await _store
          .record(transaction.transactionID)
          .add(databaseClient, transaction.jsonMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateTransaction(
    transaction,
    DatabaseClient databaseClient,
  ) async {
    try {
      assert(transaction.runtimeType == VTTransaction);
      await _store.record(transaction.transactionID).update(
            databaseClient,
            transaction.jsonMap(),
          );
    } catch (e) {
      return false;
    }
    return true;
  }
}
