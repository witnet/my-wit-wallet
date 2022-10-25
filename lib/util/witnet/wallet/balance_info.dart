import 'package:witnet/data_structures.dart';
import 'package:witnet/utils.dart';

class BalanceInfo {
  final int availableNanoWit;
  final int lockedNanoWit;
  List<Utxo> availableUtxos;
  List<Utxo> lockedUtxos;
  List<Utxo> _utxos = [];
  BalanceInfo({
    required this.availableNanoWit,
    required this.lockedNanoWit,
    required this.availableUtxos,
    required this.lockedUtxos,
  });

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
      availableNanoWit: _availableNanoWit,
      lockedNanoWit: _lockedNanoWit,
      availableUtxos: _availableUtxos,
      lockedUtxos: _lockedUtxos,
    );
  }
}
