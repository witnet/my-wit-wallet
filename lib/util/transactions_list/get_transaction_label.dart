import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:witnet/explorer.dart';

String getTransactionLabel(
    {GeneralTransaction? transaction,
    required List<String?> externalAddresses,
    required List<String?> internalAddresses,
    List<InputUtxo>? inputs,
    required Account? singleAddressAccount}) {
  String label = '';
  String _from = localization.from;
  String _to = localization.to;

  List<String?> walletAddresses = [];
  walletAddresses.addAll(externalAddresses);
  walletAddresses.addAll(internalAddresses);
  walletAddresses.add(singleAddressAccount?.address);

  switch (transaction!.type) {
    case TransactionType.value_transfer:
      if (transaction.vtt!.inputAddresses.length < 1) {
        return _from;
      }
      if (containsAnyAddress(
        transaction.vtt!.inputAddresses,
        walletAddresses,
      )) {
        label = _from;
      }
    case TransactionType.data_request:
    // TODO: Show any DRs launched or solved.
    case TransactionType.mint:
      if (containsAnyAddress(
          transaction.mint!.outputs.map((e) => e.pkh.address).toList(),
          walletAddresses)) {
        label = 'Minted';
      }
    case TransactionType.stake:
      StakeData stake = transaction.stake!;

      List<String> addresses =
          List<String>.from(stake.inputs.map((e) => e.address));
      transaction.stake!.inputs.forEach((e) {
        if (containsAnyAddress(
          addresses,
          walletAddresses,
        )) {
          label = _from;
        }
        if (containsAnyAddress(
            [stake.validator, stake.withdrawer], walletAddresses)) {
          label = _to;
        }
      });
    case TransactionType.unstake:
      if (walletAddresses.contains(transaction.unstake!.validator)) {
        label = _from;
      }
      if (walletAddresses.contains(transaction.unstake!.withdrawer)) {
        label = _to;
      }
  }
  return label;
}

bool containsAnyAddress(
  List<String> checkAddresses,
  List<String?> walletAddresses,
) =>
    walletAddresses.firstWhere((e) => checkAddresses.contains(e)) != null;
