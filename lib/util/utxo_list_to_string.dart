import 'package:witnet/data_structures.dart';

List<String> rawJsonUtxosList(List<Utxo> utxoList) {
  return utxoList.map((utxo) => utxo.toRawJson()).toList();
}
