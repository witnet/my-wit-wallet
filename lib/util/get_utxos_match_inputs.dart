import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';

List<Utxo> getUtxosMatchInputs(
    {required List<Utxo> utxoList, required List<InputUtxo> inputs}) {
  List<Utxo> matchingUtxos = [];
  //TODO: check this works with new api
  List<String> outputPointers = [];
  inputs.forEach((InputUtxo input) {
    outputPointers.add(input.inputUtxo);
  });

  for (int i = 0; i < utxoList.length; i++) {
    Utxo utxo = utxoList[i];
    if (outputPointers.contains(utxo.outputPointer.toString())) {
      matchingUtxos.add(utxo);
    }
  }
  return matchingUtxos;
}
