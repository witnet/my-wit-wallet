import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

List<Utxo> getUtxosMatchInputs(
    {required List<Utxo> utxoList, required List<InputUtxo> inputs}) {
  List<Utxo> matchingUtxos = [];
  List<OutputPointer> outputPointers = [];

  inputs.forEach((InputUtxo input) {
    outputPointers.add(input.input.outputPointer);
  });

  for (int i = 0; i < utxoList.length; i++) {
    Utxo utxo = utxoList[i];
    if (outputPointers.contains(utxo.outputPointer)) {
      matchingUtxos.add(utxo);
    }
  }
  return matchingUtxos;
}
