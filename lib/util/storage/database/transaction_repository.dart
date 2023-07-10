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
    try {
      List<ValueTransferInfo> transactions = snapshots
          .map((snapshot) => ValueTransferInfo.fromDbJson(
              snapshot.value as Map<String, dynamic>))
          .toList(growable: false);
      return transactions;
    } catch (e) {
      return [];
    }
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

class MintEntry {
  MintEntry({
    required this.blockHash,
    required this.outputs,
    required this.timestamp,
    required this.epoch,
    required this.reward,
    required this.fees,
    required this.valueTransferCount,
    required this.dataRequestCount,
    required this.commitCount,
    required this.revealCount,
    required this.tallyCount,
    required this.status,
    required this.type,
  });
  final String blockHash;
  final List<ValueTransferOutput> outputs;
  final int timestamp;
  final int epoch;
  final int reward;
  final int fees;
  final int valueTransferCount;
  final int dataRequestCount;
  final int commitCount;
  final int revealCount;
  final int tallyCount;
  final String status;
  final String type;

  bool containsAddress(String address) {
    bool response = false;
    outputs.forEach((element) {
      if (element.pkh.address == address) response = true;
    });
    return response;
  }

  Map<String, dynamic> jsonMap() => {
        "block_hash": blockHash,
        "outputs": List<Map<String, dynamic>>.from(
            outputs.map((x) => x.jsonMap(asHex: true))),
        "timestamp": timestamp,
        "epoch": epoch,
        "reward": reward,
        "fees": fees,
        "vtt_count": valueTransferCount,
        "drt_count": dataRequestCount,
        "commit_count": commitCount,
        "reveal_count": revealCount,
        "tally_count": tallyCount,
        "status": status,
        "type": type,
      };

  factory MintEntry.fromJson(Map<String, dynamic> json) => MintEntry(
        blockHash: json["block_hash"],
        outputs: List<ValueTransferOutput>.from(
            json["outputs"].map((x) => ValueTransferOutput.fromJson(x))),
        timestamp: json["timestamp"],
        epoch: json["epoch"],
        reward: json["reward"],
        fees: json["fees"],
        valueTransferCount: json["vtt_count"],
        dataRequestCount: json["drt_count"],
        commitCount: json["commit_count"],
        revealCount: json["reveal_count"],
        tallyCount: json["tally_count"],
        status: json["status"],
        type: json["type"],
      );

  factory MintEntry.fromBlockMintInfo(BlockInfo blockInfo, MintInfo mintInfo) =>
      MintEntry(
        blockHash: mintInfo.blockHash,
        outputs: mintInfo.outputs,
        timestamp: blockInfo.timestamp,
        epoch: blockInfo.epoch,
        reward: blockInfo.reward,
        fees: blockInfo.fees,
        valueTransferCount: blockInfo.valueTransferCount,
        dataRequestCount: blockInfo.dataRequestCount,
        commitCount: blockInfo.commitCount,
        revealCount: blockInfo.revealCount,
        tallyCount: blockInfo.tallyCount,
        status: mintInfo.status,
        type: mintInfo.type,
      );
}

class MintRepository extends _TransactionRepository {
  final StoreRef _store = stringMapStoreFactory.store("mints");

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
  Future<List<MintEntry>> getAllTransactions(
      DatabaseClient databaseClient) async {
    final snapshots = await _store.find(databaseClient);
    try {
      List<MintEntry> transactions = snapshots
          .map((snapshot) =>
              MintEntry.fromJson(snapshot.value as Map<String, dynamic>))
          .toList(growable: false);
      return transactions;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> insertTransaction(
    transaction,
    DatabaseClient databaseClient,
  ) async {
    try {
      assert(transaction.runtimeType == MintEntry);
      await _store
          .record(transaction.blockHash)
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
      assert(transaction.runtimeType == MintEntry);
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
