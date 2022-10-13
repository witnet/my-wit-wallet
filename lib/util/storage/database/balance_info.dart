import 'dart:convert';

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
}
