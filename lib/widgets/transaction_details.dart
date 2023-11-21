import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_label.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:my_wit_wallet/widgets/speedup_btn.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';

typedef void VoidCallback();

class TransactionDetails extends StatelessWidget {
  final GeneralTransaction transaction;
  final GeneralTransactionCallback speedUpTx;
  final VoidCallback goToList;
  final Wallet currentWallet;

  const TransactionDetails({
    required this.currentWallet,
    required this.transaction,
    required this.speedUpTx,
    required this.goToList,
  });

  List<String> get externalAddresses {
    return currentWallet.externalAccounts.values
        .map((account) => account.address)
        .toList();
  }

  List<String> get internalAddresses {
    return currentWallet.internalAccounts.values
        .map((account) => account.address)
        .toList();
  }

  Account? get singleAddressAccount {
    return currentWallet.walletType == WalletType.single
        ? currentWallet.masterAccount
        : null;
  }

  Widget _buildOutput(
      ThemeData theme, ValueTransferOutput output, bool isLastOutput) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    Widget timelock = SizedBox(height: 0);
    if (output.timeLock != 0) {
      timelock = Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            Text(output.timeLock.toInt().formatDate(),
                style: theme.textTheme.bodySmall)
          ]));
    }
    return Container(
        padding: EdgeInsets.only(top: 16, bottom: 16),
        decoration: BoxDecoration(
          color: WitnetPallet.transparent,
          border: Border(
              bottom: BorderSide(
            color: !isLastOutput
                ? extendedTheme.txBorderColor!
                : WitnetPallet.transparent,
            width: 1,
          )),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(output.pkh.address.toString(),
                      style: extendedTheme.monoSmallText),
                  SizedBox(height: 8),
                  Text(
                      '${output.value.toInt().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                      style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            SizedBox(width: 8),
            timelock,
          ],
        ));
  }

  Widget _buildInput(ThemeData theme, InputUtxo input, bool isLastInput) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: WitnetPallet.transparent,
          border: Border(
              bottom: BorderSide(
            color: !isLastInput
                ? extendedTheme.txBorderColor!
                : WitnetPallet.transparent,
            width: 1,
          )),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(input.address.toString(), style: extendedTheme.monoSmallText),
            SizedBox(height: 8),
            Text(
                '${input.value.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                style: theme.textTheme.labelMedium),
          ],
        ));
  }

  bool _isPendingTransaction(String status) {
    return status.toLowerCase() == "pending";
  }

  Widget buildSpeedUpBtn() {
    return SpeedUpBtn(
        speedUpTx: (GeneralTransaction tx) => speedUpTx(tx),
        transaction: transaction);
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String label = '';
    if (transaction.txnType == TransactionType.value_transfer) {
      label = getTransactionLabel(externalAddresses, internalAddresses,
          transaction.vtt!.inputs, singleAddressAccount, context);
    }
    List<ValueTransferOutput> outputs =
        transaction.txnType == TransactionType.value_transfer
            ? transaction.vtt!.outputs
            : transaction.mint!.outputs;
    return ClosableView(closeSetting: goToList, children: [
      Text(
        localization.transactionDetails,
        style: theme.textTheme.titleLarge,
      ),
      SizedBox(height: 24),
      InfoElement(
          label: localization.status,
          text: transaction.status.capitalize(),
          color: theme.textTheme.labelMedium?.color),
      InfoElement(
        label: localization.transactionId,
        text: transaction.txnHash,
        url: 'https://witnet.network/search/${transaction.txnHash}',
      ),
      InfoElement(
          label: localization.epoch,
          text: _isPendingTransaction(transaction.status)
              ? '_'
              : transaction.epoch.toString()),
      InfoElement(
          label: localization.type,
          text: transaction.type.split('_').join(' ').toTitleCase()),
      InfoElement(
          label: transaction.txnType == TransactionType.value_transfer
              ? localization.feesPayed
              : localization.feesCollected,
          text:
              '${transaction.fee.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
      InfoElement(
          label: localization.timestamp,
          text: _isPendingTransaction(transaction.status)
              ? '_'
              : transaction.txnTime.formatDate()),
      transaction.txnType == TransactionType.value_transfer
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                localization.inputs,
                style: theme.textTheme.displaySmall,
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: NeverScrollableScrollPhysics(),
                itemCount: transaction.vtt!.inputs.length,
                itemBuilder: (context, index) {
                  return _buildInput(theme, transaction.vtt!.inputs[index],
                      index + 1 == transaction.vtt!.inputs.length);
                },
              ),
              SizedBox(height: 16),
            ])
          : Container(),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          localization.outputs,
          style: theme.textTheme.displaySmall,
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: NeverScrollableScrollPhysics(),
          itemCount: outputs.length,
          itemBuilder: (context, index) {
            return _buildOutput(
                theme, outputs[index], index + 1 == outputs.length);
          },
        ),
      ]),
      SizedBox(height: 8),
      transaction.status == 'pending' && label == localization.to
          ? buildSpeedUpBtn()
          : Container(),
    ]);
  }
}
