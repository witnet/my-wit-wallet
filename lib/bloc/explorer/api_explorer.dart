import 'dart:math';

import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

import 'package:witnet_wallet/constants.dart';
import 'package:witnet_wallet/util/storage/cache/transaction_cache.dart';

import '../../shared/api_database.dart';
import '../../shared/locator.dart';
import '../../util/storage/database/account.dart';

enum ExplorerQuery {
  hash,
  home,
  network,
  status,
  pending,
  addressList,
  address,
  blockchain,
  tapi,
  utxos,
  utxosMulti,
  sendVtt,
  sendTransaction,
}

class ApiExplorer {
  late ExplorerClient client;
  late Status status;
  TransactionCache cache = TransactionCache();
  ApiExplorer() {
    client = (USE_EXPLORER_DEV)
        ? ExplorerClient(
            url: EXPLORER_DEV_ADDRESS, mode: ExplorerMode.development)
        : ExplorerClient(url: EXPLORER_ADDRESS, mode: ExplorerMode.production);
  }

  Future<dynamic> hash(String value, [bool simple = true]) async {
    try {
      await delay();
      return await client.hash(value, simple);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Home> home() async {
    try {
      await delay();
      return await client.home();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Network> network() async {
    try {
      await delay();
      return await client.network();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Status> getStatus() async {
    try {
      await delay();
      status = await client.status();
      return status;
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> pending() async {
    try {
      await delay();
      return await client.mempool();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> richList({int start = 0, int stop = 1000}) async {
    try {
      await delay();
      return await client.richList(start: start, stop: stop);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> address({required String value, required String tab}) async {
    try {
      await delay();
      return await client.address(value: value, tab: tab);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Blockchain> blockchain({int block = -100}) async {
    try {
      await delay();
      return await client.blockchain(block: block);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Tapi> tapi() async {
    try {
      await delay();
      return await client.tapi();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<List<Utxo>> utxos({required String address}) async {
    try {
      await delay();
      var tmp = await client.getUtxoInfo(address: address);
      return tmp;
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Map<String, List<Utxo>>> utxosMulti(
      {required List<String> addressList}) async {
    try {
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
      Map<String, List<Utxo>> _utxos = {};
      for (int i = 0; i < addressChunks.length; i++) {
        _utxos
            .addAll(await client.getMultiUtxoInfo(addresses: addressChunks[i]));
        await delay();
      }
      return _utxos;
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Account> updateAccountVtts(Account account) async {
    try {
      ApiDatabase db = Locator.instance.get<ApiDatabase>();

      /// get the list of value transfer hashes from the explorer for a given address.
      AddressValueTransfers vtts = await getValueTransferHashes(account);

      List<String> vttsToUpdate = [];
      vttsToUpdate.addAll(vtts.transactionHashes);

      List<String> vttsInDb = [];

      ///
      vttsToUpdate.retainWhere((txnId) => !vttsInDb.contains(txnId));

      for (int i = 0; i < vttsToUpdate.length; i++) {
        try {
          ValueTransferInfo vtt = await getVtt(vttsToUpdate[i]);
          await db.addVtt(vtt);
        } catch (e) {
          print('Error adding vtt to database $e');
          rethrow;
        }
      }

      account.setBalance();
    } catch (e) {
      print('Error updating account vtts and balance $e');
      rethrow;
    }
    return account;
  }

  /// Send a Value Transfer Transaction
  Future<dynamic> sendVtTransaction(VTTransaction transaction) async {
    try {
      await delay();
      return await client.send(transaction: {
        'transaction': {'ValueTransfer': transaction.jsonMap(asHex: true)}
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Send a Generic Transaction
  Future<dynamic> sendTransaction(Transaction transaction) async {
    try {
      await delay();
      return await client.send(transaction: transaction.jsonMap(asHex: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delay() async {
    await Future.delayed(Duration(milliseconds: EXPLORER_DELAY_MS));
  }

  /// get the list of value transfer hashes from the explorer for a given address.
  Future<AddressValueTransfers> getValueTransferHashes(Account account) async {
    AddressValueTransfers vtts =
        await address(value: account.address, tab: 'value_transfers');
    return vtts;
  }

  /// get the ValueTransferInfo from the explorer for a given transaction ID.
  Future<ValueTransferInfo> getVtt(String transactionId) async {
    var result = await hash(transactionId);
    return result as ValueTransferInfo;
  }

  Future<dynamic> priority() async {
    return Future.delayed(const Duration(milliseconds: 500), () {
      try {
        // return await client.priority();
        // TODO: Remove when implemented
        var random = Random();

        return {
          "drtStinky": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "drtLow": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "drtMedium": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "drtHigh": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "drtOpulent": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "vttStinky": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "vttLow": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "vttMedium": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "vttHigh": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
          "vttOpulent": {
            "priority": {
              "nanoWit": random.nextInt(100).toString(),
              "subNanoWit": random.nextInt(100).toString()
            },
            "timeToBlock": random.nextInt(100).toString(),
          },
        };
      } catch (e) {
        rethrow;
      }
    });
  }

  bool isCached(String hash) {
    return cache.containsHash(hash);
  }
}
