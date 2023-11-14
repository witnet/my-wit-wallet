import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

extension UtxoExtenstion on Utxo {
  bool locked() {
    if (timelock > 0) {
      int _ts = timelock * 1000;
      DateTime _timelock = DateTime.fromMillisecondsSinceEpoch(_ts);
      int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      if (_timelock.millisecondsSinceEpoch > currentTimestamp) return true;
      return false;
    }
    return false;
  }
}

typedef IndexedAccountMap = Map<int, Account>;
typedef AddressedAccountMap = Map<String, Account>;

extension AccountMapExtenstion on IndexedAccountMap {
  IndexedAccountMap byIndex() {
    return Map.fromEntries(
        entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }
}

typedef UtxoList = List<Utxo>;

extension UtxoListExtension on List<Utxo> {
  List<String> rawJsonList() => this.map((utxo) => utxo.toRawJson()).toList();

  int valueNanoWit() {
    return this
        .map((Utxo utxo) => utxo.value)
        .toList()
        .reduce((value, element) => value + element);
  }

  List<Utxo> filterPending({required List<ValueTransferInfo> pendingVtts}) {
    List<Utxo> filteredUtxos = [];
    List<OutputPointer> outputPointers = [];

    for (int i = 0; i < pendingVtts.length; i++) {
      pendingVtts[i].inputs.forEach((InputUtxo input) {
        outputPointers.add(input.input.outputPointer);
      });
    }

    for (int i = 0; i < this.length; i++) {
      Utxo currentUtxo = this[i];
      if (!outputPointers.contains(currentUtxo.outputPointer)) {
        filteredUtxos.add(currentUtxo);
      }
    }
    return filteredUtxos;
  }

  List<Utxo> matchInputs({required List<InputUtxo> inputs}) {
    List<Utxo> matchingUtxos = [];
    List<OutputPointer> outputPointers = [];

    inputs.forEach((InputUtxo input) {
      outputPointers.add(input.input.outputPointer);
    });

    for (int i = 0; i < this.length; i++) {
      Utxo utxo = this[i];
      if (outputPointers.contains(utxo.outputPointer)) {
        matchingUtxos.add(utxo);
      }
    }
    return matchingUtxos;
  }

  bool sameList(List<Utxo> other) {
    int currentLength = this.length;
    int newLength = other.length;
    bool isSameList = true;
    if (currentLength == newLength) {
      other.forEach((element) {
        bool containsUtxo = this.rawJsonList().contains(element.toRawJson());
        if (!containsUtxo) {
          isSameList = false;
        }
      });
    } else {
      isSameList = false;
    }
    return isSameList;
  }
}
