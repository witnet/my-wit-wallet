import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

List<Utxo> filterUsedUtxos(
    {required List<Utxo> utxoList,
    required List<ValueTransferInfo> pendingVtts}) {
  List<Utxo> filteredUtxos = [];
  List<OutputPointer> outputPointers = [];

  for (int i = 0; i < pendingVtts.length; i++) {
    pendingVtts[i].inputs.forEach((InputUtxo input) {
      outputPointers.add(input.input.outputPointer);
    });
  }

  for (int i = 0; i < utxoList.length; i++) {
    Utxo currentUtxo = utxoList[i];
    if (!outputPointers.contains(currentUtxo.outputPointer)) {
      filteredUtxos.add(currentUtxo);
    }
  }
  return filteredUtxos;
}
