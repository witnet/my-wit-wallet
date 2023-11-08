import 'package:sembast/sembast.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';

abstract class _AccountRepository {
  Future<bool> insertAccount(
    Account account,
    DatabaseClient databaseClient,
  );

  Future<bool> updateAccount(
    Account account,
    DatabaseClient databaseClient,
  );

  Future<bool> deleteAccount(
    String account,
    DatabaseClient databaseClient,
  );

  Future<List<Account>> getAccounts(DatabaseClient databaseClient);
}

class AccountRepository extends _AccountRepository {
  final StoreRef _store = stringMapStoreFactory.store("accounts");

  @override
  Future<bool> insertAccount(
    Account account,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store
          .record(account.address)
          .add(databaseClient, account.jsonMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateAccount(
    Account account,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store
          .record(account.address)
          .update(databaseClient, account.jsonMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteAccount(
    String account,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store.record(account).delete(databaseClient);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Account?> getAccount(
      String address, DatabaseClient databaseClient) async {
    try {
      dynamic accountDbJson = await _store.record(address).get(databaseClient);

      Account accountEntry = Account.fromJson(accountDbJson);

      return accountEntry;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Account>> getAccounts(DatabaseClient databaseClient) async {
    final List<RecordSnapshot<dynamic, dynamic>> snapshots =
        await _store.find(databaseClient);

    List<Account> accounts = snapshots
        .map((snapshot) => Account.fromJson(snapshot.value))
        .toList(growable: false);
    return accounts;
  }
}
