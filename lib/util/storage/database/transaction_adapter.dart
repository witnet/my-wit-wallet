import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

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
  final List<String> inputAddresses;
  final List<ValueTransferOutput> outputs;
  final List<String> outputAddresses;
  final int weight;
  final int priority;
  final bool confirmed;
  final bool reverted;

  VttData(
      {required this.inputs,
      required this.inputAddresses,
      required this.outputs,
      required this.outputAddresses,
      required this.weight,
      required this.confirmed,
      required this.reverted,
      required this.priority});
}

class GeneralTransaction extends HashInfo {
  MintData? mint;
  VttData? vtt;
  final int fee;
  final int? epoch;

  GeneralTransaction(
      {required blockHash,
      required this.epoch,
      required this.fee,
      required hash,
      required status,
      required time,
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
          epoch: valueTransferInfo.epoch,
          fee: valueTransferInfo.fee,
          hash: valueTransferInfo.hash,
          status: valueTransferInfo.status,
          time: valueTransferInfo.timestamp,
          type: valueTransferInfo.type,
          mint: null,
          vtt: VttData(
              inputs: valueTransferInfo.inputUtxos,
              inputAddresses: valueTransferInfo.inputAddresses,
              confirmed: valueTransferInfo.confirmed,
              reverted: valueTransferInfo.reverted,
              outputs: valueTransferInfo.outputs,
              outputAddresses: valueTransferInfo.outputAddresses,
              weight: valueTransferInfo.weight,
              priority: valueTransferInfo.priority));

  ValueTransferInfo toValueTransferInfo() => ValueTransferInfo(
        block: blockHash ??
            '0000000000000000000000000000000000000000000000000000000000000000',
        fee: fee,
        inputUtxos: vtt?.inputs ?? [],
        outputs: vtt?.outputs ?? [],
        priority: vtt?.priority ?? 0,
        status: status,
        epoch: epoch ?? 0,
        hash: txnHash,
        timestamp: txnTime,
        weight: vtt?.weight ?? 0,
        confirmed: vtt?.confirmed ?? false,
        reverted: vtt?.reverted ?? false,
        inputAddresses: vtt?.inputAddresses ?? [],
        outputAddresses: vtt?.outputAddresses ?? [],
        value: 0,
        inputsMerged: [],
        outputValues: [],
        timelocks: [],
        utxos: [],
        utxosMerged: [],
        trueOutputAddresses: [],
        changeOutputAddresses: [],
        trueValue: 0,
        changeValue: 0,
      );
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
    required this.confirmed,
    required this.reverted,
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
  final TxStatusLabel status;
  final TransactionType type;
  final bool confirmed;
  final bool reverted;

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
        'confirmed': confirmed,
        'reverted': reverted,
        "status": status.toString(),
        "type": type.toString(),
      };

  factory MintEntry.fromJson(Map<String, dynamic> json) {
    return MintEntry(
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
      confirmed: json['confirmed'] ?? false,
      reverted: json['reverted'] ?? false,
      status: TransactionStatus.fromJson(json).status,
      type: TransactionType.mint,
    );
  }

  factory MintEntry.fromBlockMintInfo(
          BlockInfo blockInfo, BlockDetails blockDetails) =>
      MintEntry(
        blockHash: blockDetails.mintInfo.blockHash,
        outputs: blockDetails.mintInfo.outputs,
        timestamp: blockInfo.timestamp,
        epoch: blockInfo.epoch,
        reward: blockInfo.reward,
        fees: blockInfo.fees,
        valueTransferCount: blockInfo.valueTransferCount,
        dataRequestCount: blockInfo.dataRequestCount,
        commitCount: blockInfo.commitCount,
        revealCount: blockInfo.revealCount,
        tallyCount: blockInfo.tallyCount,
        status: TransactionStatus.fromJson({
          'confirmed': blockDetails.confirmed,
          'reverted': blockDetails.reverted
        }).status,
        type: TransactionType.mint,
        confirmed: blockDetails.confirmed,
        reverted: blockDetails.reverted,
      );
}
