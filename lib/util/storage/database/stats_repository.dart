import 'package:sembast/sembast.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';

abstract class _StatsRepository {
  Future<bool> insertStats(
    AccountStats stats,
    DatabaseClient databaseClient,
  );

  Future<bool> updateStats(
    AccountStats stats,
    DatabaseClient databaseClient,
  );

  Future<bool> deleteStats(
    String stats,
    DatabaseClient databaseClient,
  );

  Future<List<AccountStats>> getAllStats(DatabaseClient databaseClient);

  Future<AccountStats?> getStatsByAddress(
      DatabaseClient databaseClient, String address);
}

class StatsRepository extends _StatsRepository {
  final StoreRef _store = stringMapStoreFactory.store("stats");

  @override
  Future<bool> insertStats(
    AccountStats stats,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store.record(stats.address).add(databaseClient, stats.jsonMap());
      return true;
    } catch (e) {
      print('Error adding stats record $e');
      return false;
    }
  }

  @override
  Future<bool> updateStats(
    AccountStats stats,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store
          .record(stats.address)
          .update(databaseClient, stats.jsonMap());
      return true;
    } catch (e) {
      print('Error updating stats record $e');
      return false;
    }
  }

  @override
  Future<bool> deleteStats(
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

  @override
  Future<AccountStats?> getStatsByAddress(
      DatabaseClient databaseClient, String address) async {
    try {
      final result = await _store.record(address).get(databaseClient);
      if (result != null) {
        return AccountStats.fromJson(result as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (err) {
      print('Error getting stats record from address $address :: $err');
      return null;
    }
  }

  @override
  Future<List<AccountStats>> getAllStats(DatabaseClient databaseClient) async {
    final List<RecordSnapshot<dynamic, dynamic>> snapshots =
        await _store.find(databaseClient);

    List<AccountStats> accounts = snapshots
        .map((snapshot) => AccountStats.fromJson(snapshot.value))
        .toList(growable: false);
    return accounts;
  }
}
