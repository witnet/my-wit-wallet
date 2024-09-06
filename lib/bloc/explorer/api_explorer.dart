import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';

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
  ApiExplorer() {

    if(USE_EXPLORER_MOCK) {
      client = ExplorerClient(
          url: EXPLORER_MOCK_ADDRESS, mode: ExplorerMode.development);
    } else {
      client = (USE_EXPLORER_DEV)
          ? ExplorerClient(
          url: EXPLORER_DEV_ADDRESS, mode: ExplorerMode.development)
          : ExplorerClient(url: EXPLORER_ADDRESS, mode: ExplorerMode.production);
    }
  }

  Future<dynamic> hash(String value, [bool simple = true]) async {
    try {
      await delay();
      return await client.hash(value: value, simple: simple, findAll: true);
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

  Future<String?> getVersion() async {
    try {
      await delay();
      return await client.version();
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

  Future<PaginatedRequest<dynamic>> address(
      {required String value, required String tab}) async {
    try {
      await delay();
      return await client.address(value: value, tab: tab, findAll: true)
          as PaginatedRequest<dynamic>;
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
      Map<String, List<Utxo>> multiUtxo;
      try {
        multiUtxo = await client.getMultiUtxoInfo(addresses: addressChunks[i]);
      } catch (err) {
        print('Error getting multi utxo info $err');
        rethrow;
      }
      if (multiUtxo.keys.length > 0) _utxos.addAll(multiUtxo);
      await delay();
    }
    return _utxos;
  }

  Future<Account> updateAccountVtts(Account account) async {
    try {
      ApiDatabase db = Locator.instance.get<ApiDatabase>();

      /// get the list of value transfer hashes from the explorer for a given address.
      AddressValueTransfers vtts = await getValueTransferHashes(account);

      List<String> vttsToUpdate = [];
      vttsToUpdate.addAll(vtts.addressValueTransfers.map((e) => e.hash));

      List<String> vttsInDb = [];

      vttsToUpdate.retainWhere((txnId) => !vttsInDb.contains(txnId));

      for (int i = 0; i < vttsToUpdate.length; i++) {
        try {
          ValueTransferInfo? vtt = await getVtt(vttsToUpdate[i]);
          if (vtt != null) await db.addVtt(vtt);
        } catch (e) {
          print('Error adding vtt to database $e');
          rethrow;
        }
      }
    } catch (e) {
      print('Error updating account vtts and balance $e');
      rethrow;
    }
    return account;
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

  Future<PrioritiesEstimate> priority() async {
    try {
      return await client.valueTransferPriority();
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
        (await address(value: account.address, tab: 'value_transfers')).data;
    return vtts;
  }

  /// get the ValueTransferInfo from the explorer for a given transaction ID.
  Future<ValueTransferInfo?> getVtt(String transactionId) async {
    return await hash(transactionId) as ValueTransferInfo?;
  }

  Future<MintEntry> getMint(BlockInfo blockInfo) async {
    String _hash = blockInfo.hash;
    var result = await Locator.instance.get<ApiExplorer>().hash(_hash);

    /// create a MintEntry from the BlockInfo and MintInfo
    BlockDetails blockDetails = result as BlockDetails;
    MintEntry mintEntry = MintEntry.fromBlockMintInfo(
      blockInfo,
      blockDetails,
    );
    return mintEntry;
  }
}
