import 'package:sembast/sembast.dart';
import 'wallet.dart';

abstract class _WalletRepository {
  Future<bool> insertWallet(
    Wallet wallet,
    DatabaseClient databaseClient,
  );

  Future<bool> updateWallet(
    Wallet wallet,
    DatabaseClient databaseClient,
  );

  Future<bool> deleteWallet(
    String walletId,
    DatabaseClient databaseClient,
  );

  Future<List<Wallet>> getWallets(DatabaseClient databaseClient);
}

class WalletRepository extends _WalletRepository {
  final StoreRef _store = stringMapStoreFactory.store("wallets");

  @override
  Future<bool> deleteWallet(
      String walletId, DatabaseClient databaseClient) async {
    try {
      await _store.record(walletId).delete(databaseClient);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Wallet>> getWallets(DatabaseClient databaseClient) async {
    final List<RecordSnapshot<dynamic, dynamic>> snapshots =
        await _store.find(databaseClient);

    List<Wallet> wallets = snapshots
        .map((snapshot) => Wallet.fromJson(snapshot.value))
        .toList(growable: false);
    return wallets;
  }

  @override
  Future<bool> insertWallet(
    Wallet wallet,
    DatabaseClient databaseClient,
  ) async {
    try {
      await _store.record(wallet.id).add(databaseClient, _mapWallet(wallet));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> updateWallet(
      Wallet wallet, DatabaseClient databaseClient) async {
    try {
      await _store.record(wallet.id).update(databaseClient, _mapWallet(wallet));
      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, String> _mapWallet(Wallet wallet) => {
        'id': wallet.id,
        'name': wallet.name,
        'description': wallet.description ?? '',
        'xprv': wallet.xprv!,
        'externalXpub': wallet.externalXpub!,
        'internalXpub': wallet.internalXpub!,
      };
}
