import 'dart:convert';
import 'package:witnet/constants.dart';
import 'package:witnet/data_structures.dart';

class BalanceInfo {
  late final int availableNanoWit;
  late final int lockedNanoWit;
  List<Utxo> availableUtxos;
  List<Utxo> lockedUtxos;
  BalanceInfo({
    int availableNanoWIT = 0,
    int lockedNanoWIT = 0,
    required this.availableUtxos,
    required this.lockedUtxos,
  })  : this.availableNanoWit = availableNanoWIT,
        this.lockedNanoWit = lockedNanoWIT;

  factory BalanceInfo.fromUtxoList(List<Utxo> utxos) {
    int _lockedNanoWit = 0;
    int _availableNanoWit = 0;
    List<Utxo> _lockedUtxos = [];
    List<Utxo> _availableUtxos = [];
    utxos.forEach((Utxo utxo) {
      if (utxo.timelock > 0) {
        int ts = utxo.timelock * 1000;
        int currentTimestamp = DateTime.now().millisecondsSinceEpoch;

        if (ts > currentTimestamp) {
          /// utxo is still locked
          _lockedNanoWit += utxo.value;
          _lockedUtxos.add(utxo);
        } else {
          _availableNanoWit += utxo.value;
          _availableUtxos.add(utxo);
        }
      } else if (utxo.timelock == 0) {
        _availableNanoWit += utxo.value;
        _availableUtxos.add(utxo);
      }
    });
    return BalanceInfo(
      availableNanoWIT: _availableNanoWit,
      lockedNanoWIT: _lockedNanoWit,
      availableUtxos: _availableUtxos,
      lockedUtxos: _lockedUtxos,
    );
  }

  List<Utxo> cover({
    required int amountNanoWit,
    required UtxoSelectionStrategy utxoStrategy,
    required UtxoPool utxoPool,
  }) {
    List<Utxo> utxos = utxoPool.sortUtxos(utxoStrategy);
    if (utxos.isEmpty) {
      return [];
    }
    int utxoValue = 0;
    utxoValue += utxos.map((e) => e.value).toList().reduce((a, b) => a + b);

    List<Utxo> selectedUtxos = [];

    if (amountNanoWit > utxoValue) {
      return [];
    }

    while (amountNanoWit > 0) {
      // since the list is sorted - take the first item
      Utxo utxo = utxos.first;
      utxos.removeAt(0);
      selectedUtxos.add(utxo);
      amountNanoWit -= utxo.value;
    }
    return selectedUtxos;
  }

  @override
  String toString() {
    return json.encode(jsonMap());
  }

  Map<String, dynamic> jsonMap() {
    return {
      "availableNanoWit": availableNanoWit,
      "lockedNanoWit": lockedNanoWit,
    };
  }

  BalanceInfo operator +(BalanceInfo other) {
    List<Utxo> _availableUtxos = [];
    _availableUtxos.addAll(availableUtxos);
    _availableUtxos.addAll(other.availableUtxos);
    List<Utxo> _lockedUtxos = [];
    _lockedUtxos.addAll(lockedUtxos);
    _lockedUtxos.addAll(other.lockedUtxos);

    return BalanceInfo(
      availableNanoWIT: availableNanoWit + other.availableNanoWit,
      lockedNanoWIT: lockedNanoWit + other.lockedNanoWit,
      availableUtxos: _availableUtxos,
      lockedUtxos: _lockedUtxos,
    );
  }

  int? weightedVttFee(int value,
      {int outputs = 1,
      UtxoSelectionStrategy selectionStrategy =
          UtxoSelectionStrategy.SmallFirst}) {
    UtxoPool utxoPool = UtxoPool();
    availableUtxos.forEach((Utxo utxo) {
      utxoPool.insert(utxo);
    });
    List<Utxo> selectedUtxos = cover(
      amountNanoWit: value,
      utxoStrategy: selectionStrategy,
      utxoPool: utxoPool,
    );
    if (selectedUtxos.isEmpty) return null;
    int changeNanoWit;
    int valuePaidNanoWit =
        BalanceInfo.fromUtxoList(selectedUtxos).availableNanoWit;
    changeNanoWit = (valuePaidNanoWit - value);
    return changeNanoWit > 0
        ? (selectedUtxos.length * INPUT_SIZE) +
            (outputs + 1 * OUTPUT_SIZE * GAMMA)
        : (selectedUtxos.length * INPUT_SIZE) + (outputs * OUTPUT_SIZE * GAMMA);
  }
}
