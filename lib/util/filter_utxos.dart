import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';

List<Utxo> filterUsedUtxos({
  required List<Utxo> utxoList,
  required List<ValueTransferInfo> pendingVtts,
  required List<StakeEntry> pendingStakes,
}) {
  List<Utxo> filteredUtxos = [];
  List<String> outputPointers = [];

  for (int i = 0; i < pendingVtts.length; i++) {
    pendingVtts[i].inputUtxos.forEach((InputUtxo input) {
      outputPointers.add(input.inputUtxo);
    });
  }
  for (int i = 0; i < pendingStakes.length; i++) {
    pendingStakes[i].inputs.forEach((StakeInput input) {
      // TODO(#): fix pending stakes
      // outputPointers.add(input.inputUtxo);
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
