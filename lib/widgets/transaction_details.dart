import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/transactions_list/transaction_utils.dart';
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
      case TransactionType.stake:
        return localization.stake;
      case TransactionType.unstake:
        return localization.unstake;
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

  bool isFromCurrentWallet(String address) {
    if (currentWallet.walletType == WalletType.single &&
        currentWallet.masterAccount!.address == address) {
      return true;
    }
    if (externalAddresses.contains(address)) {
      return true;
    }
    if (internalAddresses.contains(address)) {
      return true;
    }
    return false;
  }

  Widget buildSpecificInfo(
      {required BuildContext context,
      bool showArrow = false,
      required String label1,
      required String address1,
      required String label2,
      required String address2}) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    return ContainerBackground(
        padding: 22,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InfoCopy(
              isHashContent: true,
              isContentImportant: true,
              infoToCopy: address1,
              label: label1,
              customContent: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isFromCurrentWallet(address1)
                        ? identiconContainer(
                            extendedTheme,
                            currentWallet.id,
                          )
                        : Container(),
                    isFromCurrentWallet(address1)
                        ? SizedBox(width: 8)
                        : Container(),
                    if (address1.length > 12)
                      Text(
                        address1.cropAddress(12),
                        style: extendedTheme.monoMediumText,
                      ),
                  ]),
            ),
            showArrow
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                        Icon(FontAwesomeIcons.circleArrowDown,
                            color: theme.textTheme.bodyMedium?.color),
                        SizedBox(width: 96),
                      ])
                : Container(),
            SizedBox(height: 8),
            InfoCopy(
              isLastItem: true,
              isContentImportant: true,
              isHashContent: true,
              infoToCopy: address2,
              label: label2,
              customContent: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    isFromCurrentWallet(address2)
                        ? identiconContainer(
                            extendedTheme,
                            currentWallet.id,
                          )
                        : Container(),
                    SizedBox(width: 8),
                    if (address1.length > 12)
                      Text(
                        address2.cropAddress(12),
                        style: extendedTheme.monoMediumText,
                      ),
                  ]),
            ),
          ],
        ));
  }

  Widget buildOriginReceiverInfo(
      {required TransactionType type,
      required BuildContext context,
      required TransactionUtils transactionUtils}) {
    Widget stakeUnstakeInfo = buildSpecificInfo(
        context: context,
        label1: localization.validator,
        address1: transactionUtils.getValidatorAddress(),
        label2: localization.withdrawer,
        address2: transactionUtils.getWithdrawalAddress());
    switch (type) {
      case TransactionType.value_transfer:
        return buildSpecificInfo(
            context: context,
            showArrow: true,
            label1: localization.from,
            address1: transactionUtils.getSenderAddress(),
            label2: localization.to,
            address2: transactionUtils.getRecipientAddress());
      case TransactionType.mint:
        return Container();
      case TransactionType.stake:
        return stakeUnstakeInfo;
      case TransactionType.unstake:
        return stakeUnstakeInfo;
      case TransactionType.data_request:
        return Container();
    }
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          buildOriginReceiverInfo(
              type: transaction.type,
              context: context,
              transactionUtils: transactionUtils),
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
                      label: isMint
                          ? localization.feesCollected
                          : localization.feesPayed,
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
          // TODO: Remove stake check when speed up stake transactions are supported
          transaction.status == TxStatusLabel.pending &&
                  transaction.type != TransactionType.stake &&
                  label == localization.to
              ? buildSpeedUpBtn()
              : Container(),
        ]);
  }
}
