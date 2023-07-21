import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

enum TransactionType { mint, value_transfer }

class MintData {
  final List<ValueTransferOutput> outputs;
  final int timestamp;
  final int reward;
  final int valueTransferCount;
  final int dataRequestCount;
  final int commitCount;
  final int revealCount;
  final int tallyCount;

  MintData({
    required this.outputs,
    required this.timestamp,
    required this.reward,
    required this.valueTransferCount,
    required this.dataRequestCount,
    required this.commitCount,
    required this.revealCount,
    required this.tallyCount,
  });
}

class VttData {
  final List<InputUtxo> inputs;
  final List<ValueTransferOutput> outputs;
  final int weight;
  final int priority;

  VttData(
      {required this.inputs,
      required this.outputs,
      required this.weight,
      required this.priority});
}

class GeneralTransaction extends HashInfo {
  MintData? mint;
  VttData? vtt;
  final TransactionType txnType;
  final int fee;
  final int? epoch;

  GeneralTransaction(
      {required blockHash,
      required this.epoch,
      required this.fee,
      required hash,
      required status,
      required time,
      required this.txnType,
      required type,
      this.mint,
      this.vtt})
      : super(
            txnHash: hash,
            status: status,
            type: type,
            txnTime: time,
            blockHash: blockHash);

  factory GeneralTransaction.fromMintEntry(MintEntry mintEntry) =>
      GeneralTransaction(
          blockHash: mintEntry.blockHash,
          epoch: mintEntry.epoch,
          fee: mintEntry.fees,
          hash: mintEntry.blockHash,
          status: mintEntry.status,
          time: mintEntry.timestamp,
          type: mintEntry.type,
          txnType: TransactionType.mint,
          mint: MintData(
              commitCount: mintEntry.commitCount,
              outputs: mintEntry.outputs,
              timestamp: mintEntry.timestamp,
              reward: mintEntry.reward,
              valueTransferCount: mintEntry.valueTransferCount,
              dataRequestCount: mintEntry.dataRequestCount,
              revealCount: mintEntry.revealCount,
              tallyCount: mintEntry.tallyCount),
          vtt: null);
  factory GeneralTransaction.fromValueTransferInfo(
          ValueTransferInfo valueTransferInfo) =>
      GeneralTransaction(
          blockHash: valueTransferInfo.blockHash,
          epoch: valueTransferInfo.txnEpoch,
          fee: valueTransferInfo.fee,
          hash: valueTransferInfo.txnHash,
          status: valueTransferInfo.status,
          time: valueTransferInfo.txnTime,
          type: valueTransferInfo.type,
          txnType: TransactionType.value_transfer,
          mint: null,
          vtt: VttData(
              inputs: valueTransferInfo.inputs,
              outputs: valueTransferInfo.outputs,
              weight: valueTransferInfo.weight,
              priority: valueTransferInfo.priority));
}

class MintEntry {
  MintEntry({
    required this.blockHash,
    required this.fees,
    required this.epoch,
    // specific to mint entry
    required this.outputs,
    required this.timestamp,
    required this.reward,
    required this.valueTransferCount,
    required this.dataRequestCount,
    required this.commitCount,
    required this.revealCount,
    required this.tallyCount,
    required this.status,
    required this.type,
  });
  final String blockHash;
  final List<ValueTransferOutput> outputs;
  final int timestamp;
  final int epoch;
  final int reward;
  final int fees;
  final int valueTransferCount;
  final int dataRequestCount;
  final int commitCount;
  final int revealCount;
  final int tallyCount;
  final String status;
  final String type;

  bool containsAddress(String address) {
    bool response = false;
    outputs.forEach((element) {
      if (element.pkh.address == address) response = true;
    });
    return response;
  }

  Map<String, dynamic> jsonMap() => {
        "block_hash": blockHash,
        "outputs": List<Map<String, dynamic>>.from(
            outputs.map((x) => x.jsonMap(asHex: true))),
        "timestamp": timestamp,
        "epoch": epoch,
        "reward": reward,
        "fees": fees,
        "vtt_count": valueTransferCount,
        "drt_count": dataRequestCount,
        "commit_count": commitCount,
        "reveal_count": revealCount,
        "tally_count": tallyCount,
        "status": status,
        "type": type,
      };

  factory MintEntry.fromJson(Map<String, dynamic> json) => MintEntry(
        blockHash: json["block_hash"],
        outputs: List<ValueTransferOutput>.from(
            json["outputs"].map((x) => ValueTransferOutput.fromJson(x))),
        timestamp: json["timestamp"],
        epoch: json["epoch"],
        reward: json["reward"],
        fees: json["fees"],
        valueTransferCount: json["vtt_count"],
        dataRequestCount: json["drt_count"],
        commitCount: json["commit_count"],
        revealCount: json["reveal_count"],
        tallyCount: json["tally_count"],
        status: json["status"],
        type: json["type"],
      );

  factory MintEntry.fromBlockMintInfo(BlockInfo blockInfo, MintInfo mintInfo) =>
      MintEntry(
        blockHash: mintInfo.blockHash,
        outputs: mintInfo.outputs,
        timestamp: blockInfo.timestamp,
        epoch: blockInfo.epoch,
        reward: blockInfo.reward,
        fees: blockInfo.fees,
        valueTransferCount: blockInfo.valueTransferCount,
        dataRequestCount: blockInfo.dataRequestCount,
        commitCount: blockInfo.commitCount,
        revealCount: blockInfo.revealCount,
        tallyCount: blockInfo.tallyCount,
        status: mintInfo.status,
        type: mintInfo.type,
      );
}
