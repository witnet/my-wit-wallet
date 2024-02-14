import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';

List<Utxo> filterUsedUtxos(
    {required List<Utxo> utxoList,
    required List<ValueTransferInfo> pendingVtts}) {
  List<Utxo> filteredUtxos = [];
  List<String> outputPointers = [];

  for (int i = 0; i < pendingVtts.length; i++) {
    pendingVtts[i].inputUtxos.forEach((InputUtxo input) {
      outputPointers.add(input.inputUtxo);
    });
  }

  for (int i = 0; i < utxoList.length; i++) {
    Utxo currentUtxo = utxoList[i];
    if (!outputPointers.contains(currentUtxo.outputPointer.toString())) {
      filteredUtxos.add(currentUtxo);
    }
  }
  return filteredUtxos;
}
