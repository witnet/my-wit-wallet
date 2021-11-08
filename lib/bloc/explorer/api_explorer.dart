
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:witnet_wallet/util/storage/cache/file_manager_interface.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';

import '../../constants.dart';

class ApiExplorer {
  TransactionCache cache = TransactionCache();
  late ExplorerClient client;

  ApiExplorer() {
    client = (USE_EXPLORER_DEV)
        ? ExplorerClient(
            url: EXPLORER_DEV_ADDRESS, mode: ExplorerMode.development)
        : ExplorerClient(url: EXPLORER_ADDRESS, mode: ExplorerMode.production);
  }

  Future<dynamic> hash(String value, bool simple) async {
    if (cache.containsHash(value)) {
      return cache.getValue(value);
    }
    try {
      return await client.hash(value, simple);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Home> home() async {
    try {
      return await client.home();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Network> network() async {
    try {
      return await client.network();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Status> status() async {
    try {
      return await client.status();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> pending() async {
    try {
      return await client.pending();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> richList({int start = 0, int stop = 1000}) async {
    try {
      return await client.richList(start: start, stop: stop);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> address({required String value, required String tab}) async {
    try {
      return await client.address(value: value, tab: tab);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Blockchain> blockchain({int block = -100}) async {
    try {
      return await client.blockchain(block: block);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Tapi> tapi() async {
    try {
      return await client.tapi();
    } on ExplorerException {
      rethrow;
    }
  }

  Future<List<Utxo>> utxos({required String address}) async {
    try {
      var tmp = await client.getUtxoInfo(address: address);
      return tmp;
    } on ExplorerException {
      rethrow;
    }
  }

  Future<dynamic> sendTransaction(Transaction transaction) async {
    try {
      return await client.send(
          transaction: transaction.jsonMap(asHex: true), test: true);
    } on ExplorerException {
      rethrow;
    }
  }

  Future<Account> syncAccount(Account account) async {
    try {
      List<Utxo> utxoList = await utxos(address: account.address);
      List<ValueTransferInfo> vtts =
          await address(value: account.address, tab: 'value_transfers')
              as List<ValueTransferInfo>;
      return account;
    } catch (e) {
      throw ExplorerException(code: -4, message: 'unable to sync account');
    }
  }

  bool isCached(String hash) {
    return cache.containsHash(hash);
  }
}
