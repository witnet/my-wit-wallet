import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/transactions_list/transaction_details.dart';
import 'package:my_wit_wallet/widgets/closable_view.dart';
import 'package:my_wit_wallet/widgets/container_background.dart';
import 'package:my_wit_wallet/widgets/identicon.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:my_wit_wallet/widgets/speedup_btn.dart';
import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';

typedef void VoidCallback();

class TransactionDetails extends StatelessWidget {
  static final route = '/transaction-details';
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

  bool get isVTT => transaction.type == TransactionType.value_transfer;

  bool get isMint => transaction.type == TransactionType.mint;

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

  bool isFromCurrentWallet() {
    if (currentWallet.walletType == WalletType.single) {
      if (transaction.vtt!.inputAddresses
          .contains(singleAddressAccount?.address)) {
        return true;
      }
    }
    if (isVTT) {
      for (int i = 0; i < transaction.vtt!.inputAddresses.length; i++) {
        if (externalAddresses.contains(transaction.vtt!.inputAddresses[i])) {
          return true;
        }
        if (internalAddresses.contains(transaction.vtt!.inputAddresses[i])) {
          return true;
        }
      }
    }
    return false;
  }

  bool isToCurrentWallet() {
    if (currentWallet.walletType == WalletType.single) {
      if (transaction.vtt?.outputAddresses[0] ==
          singleAddressAccount?.address) {
        return true;
      }
    }
    if (isVTT) {
      if (externalAddresses.contains(transaction.vtt!.outputAddresses[0])) {
        return true;
      }
      if (internalAddresses.contains(transaction.vtt!.inputAddresses[0])) {
        return true;
      }
    }
    return false;
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    TransactionUtils transactionUtils = TransactionUtils(vti: transaction);
    String label = transactionUtils.getLabel();
    String? timelock = transactionUtils.timelock();

    return ClosableView(
        closeSetting: goToList,
        title: transactionType(transaction.type),
        children: [
          ContainerBackground(
              padding: 22,
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: InfoLink(
                          url:
                              'https://witnet.network/search/${transaction.txnHash}',
                          label: '',
                          text: localization.viewOnExplorer,
                          isContentImportant: true,
                        )),
                    InfoCopy(
                        label: localization.transactionId,
                        layout: InfoLayout.horizonal,
                        isContentImportant: true,
                        isHashContent: true,
                        text: transaction.txnHash.cropMiddle(14),
                        infoToCopy: transaction.txnHash),
                    _isPendingTransaction(transaction.status)
                        ? Container()
                        : InfoElement(
                            isContentImportant: true,
                            label: localization.timestamp,
                            text: transaction.txnTime.formatDate()),
                    InfoElement(
                        isContentImportant: true,
                        label: localization.status,
                        text: transactionStatus(transaction.status),
                        contentColor: getStatusColor(transaction.status, theme),
                        isLastItem: true),
                  ])),
          isVTT
              ? ContainerBackground(
                  padding: 22,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      isVTT
                          ? InfoCopy(
                              isHashContent: true,
                              isContentImportant: true,
                              infoToCopy: transactionUtils.getSenderAddress(),
                              label: localization.from,
                              customContent: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    isFromCurrentWallet()
                                        ? identiconContainer(
                                            extendedTheme,
                                            currentWallet.id,
                                          )
                                        : Container(),
                                    isFromCurrentWallet()
                                        ? SizedBox(width: 8)
                                        : Container(),
                                    Text(
                                      transactionUtils
                                          .getSenderAddress()
                                          .cropAddress(12),
                                      style: extendedTheme.monoMediumText,
                                    ),
                                  ]),
                            )
                          : Container(),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(FontAwesomeIcons.circleArrowDown,
                                color: theme.textTheme.bodyMedium?.color),
                            SizedBox(width: 96),
                          ]),
                      SizedBox(height: 8),
                      InfoCopy(
                        isLastItem: true,
                        isContentImportant: true,
                        isHashContent: true,
                        infoToCopy: transactionUtils.getRecipientAddress(),
                        label: localization.to,
                        customContent: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              isToCurrentWallet()
                                  ? identiconContainer(
                                      extendedTheme,
                                      currentWallet.id,
                                    )
                                  : Container(),
                              SizedBox(width: 8),
                              Text(
                                transactionUtils
                                    .getRecipientAddress()
                                    .cropAddress(12),
                                style: extendedTheme.monoMediumText,
                              ),
                            ]),
                      ),
                    ],
                  ))
              : Container(),
          ContainerBackground(
              padding: 22,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InfoElement(
                      label: localization.amount,
                      text: transactionUtils.getTransactionValue().amount,
                      isContentImportant: true),
                  InfoElement(
                      label: isVTT
                          ? localization.feesPayed
                          : localization.feesCollected,
                      text:
                          '${transaction.fee.standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
                      isContentImportant: true),
                  InfoElement(
                      label: localization.total,
                      text: transactionUtils.getTransactionValue().amount,
                      isContentImportant: true,
                      isLastItem: timelock == null),
                  timelock != null
                      ? InfoElement(
                          label: localization.timelock,
                          text: transactionUtils.timelock()!,
                          isContentImportant: true,
                          isLastItem: true)
                      : Container(),
                ],
              )),
          SizedBox(height: 8),
          transaction.status == TxStatusLabel.pending &&
                  label == localization.to
              ? buildSpeedUpBtn()
              : Container(),
        ]);
  }
}
