import 'package:my_wit_wallet/bloc/explorer/api_explorer.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/cache/read_through.dart';
import 'package:witnet/explorer.dart';

class VttGetThroughBlockExplorer {
  ApiExplorer apiExplorer = Locator.instance.get<ApiExplorer>();
  ApiDatabase db = Locator.instance.get<ApiDatabase>();

  late ReadThrough<ValueTransferInfo> _vttGetThroughBlockExplorer;

  VttGetThroughBlockExplorer() {
    _vttGetThroughBlockExplorer = ReadThrough(
      (String hash) async => await apiExplorer.hash(hash),
      (ValueTransferInfo valueTransferInfo) async =>
          await db.addVtt(valueTransferInfo),
      (String hash) async => await db.getVtt(hash),
    );
  }

  Future<ValueTransferInfo?> get(String key) async {
    return await _vttGetThroughBlockExplorer.get(key);
  }
}
