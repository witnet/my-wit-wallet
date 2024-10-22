import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/transactions_list/transaction_details.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:my_wit_wallet/widgets/container_background.dart';
import 'package:my_wit_wallet/widgets/speedup_btn.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
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

  String transactionType(TransactionType status) {
    switch (status) {
      case TransactionType.value_transfer:
        return localization.valueTransferTxn;
      case TransactionType.mint:
        return localization.mintTxn;
      case TransactionType.data_request:
        return localization.dataRequestTxn;
    }
  }

  String transactionStatus(TxStatusLabel status) {
    switch (status) {
      case TxStatusLabel.confirmed:
        return localization.confirmed;
      case TxStatusLabel.mined:
        return localization.mined;
      case TxStatusLabel.pending:
        return localization.pending;
      case TxStatusLabel.reverted:
        return localization.reverted;
      case TxStatusLabel.unknown:
        return 'Loading...';
    }
  }

  bool _isPendingTransaction(TxStatusLabel status) {
    return status == TxStatusLabel.pending;
  }

  Widget buildSpeedUpBtn() {
    return SpeedUpBtn(
        speedUpTx: (GeneralTransaction tx) => speedUpTx(tx),
        transaction: transaction);
  }

  Color? getStatusColor(TxStatusLabel status, ThemeData theme) {
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    switch (status) {
      case TxStatusLabel.pending:
        return extendedTheme.warningColor;
      case TxStatusLabel.confirmed:
        return extendedTheme.txValuePositiveColor;
      case TxStatusLabel.mined:
        return extendedTheme.txValuePositiveColor;
      case TxStatusLabel.reverted:
        return extendedTheme.txValueNegativeColor;
      case TxStatusLabel.unknown:
        return theme.textTheme.labelMedium?.color;
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    TransactionUtils transactionUtils = TransactionUtils(vti: transaction);
    String label = transactionUtils.getLabel();
    String? timelock = transactionUtils.timelock();
    return ClosableView(closeSetting: goToList, children: [
      Text(
        localization.transactionDetails,
        style: theme.textTheme.titleLarge,
      ),
      SizedBox(height: 24),
      ContainerBackground(
          content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InfoElement(
              label: localization.status,
              text: transactionStatus(transaction.status),
              url: 'https://witnet.network/search/${transaction.txnHash}',
              color: getStatusColor(transaction.status, theme)),
          InfoElement(
              label: localization.type,
              text: transactionType(transaction.type)),
          InfoElement(
              label: localization.from.toTitleCase(),
              copyText: transactionUtils.getSenderAddress(),
              contentFontStyle: extendedTheme.monoBoldText!,
              text: transactionUtils.getSenderAddress().cropMiddle(24)),
          InfoElement(
              label: localization.to,
              copyText: transactionUtils.getRecipientAddress(),
              contentFontStyle: extendedTheme.monoBoldText!,
              text: transactionUtils.getRecipientAddress().cropMiddle(24)),
          InfoElement(
            label: localization.amount,
            text: transactionUtils.getTransactionValue().amount,
          ),
          timelock != null
              ? InfoElement(
                  label: localization.timelock,
                  text: transactionUtils.timelock()!,
                )
              : Container(),
          InfoElement(
              label: transaction.type == TransactionType.value_transfer
                  ? localization.feesPayed
                  : localization.feesCollected,
              text:
                  '${transaction.fee.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
        ],
      )),
      ContainerBackground(
          content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
            InfoElement(
              label: localization.transactionId,
              text: transaction.txnHash.cropMiddle(24),
              copyText: transaction.txnHash,
              url: 'https://witnet.network/search/${transaction.txnHash}',
            ),
            InfoElement(
                label: localization.timestamp,
                text: _isPendingTransaction(transaction.status)
                    ? '_'
                    : transaction.txnTime.formatDate()),
            InfoElement(
                label: localization.epoch,
                text: _isPendingTransaction(transaction.status)
                    ? '_'
                    : transaction.epoch.toString()),
          ])),
      SizedBox(height: 8),
      transaction.status == TxStatusLabel.pending && label == localization.to
          ? buildSpeedUpBtn()
          : Container(),
    ]);
  }
}
