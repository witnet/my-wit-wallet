import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_address.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_label.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';

typedef void GeneralTransactionCallback(GeneralTransaction? value);

class TransactionsItem extends StatefulWidget {
  final GeneralTransaction transaction;
  final GeneralTransactionCallback showDetails;
  TransactionsItem(
      {Key? key, required this.transaction, required this.showDetails})
      : super(key: key);

  @override
  TransactionsItemState createState() => TransactionsItemState();
}

class TransactionsItemState extends State<TransactionsItem> {
  GeneralTransaction? transactionDetails;
  final ScrollController _scroller = ScrollController();
  Wallet currentWallet =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;
  dynamic nextAction;
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scroller.dispose();
    super.dispose();
  }

  int receiveValue(GeneralTransaction vti) {
    int nanoWitvalue = 0;
    if (vti.txnType == TransactionType.value_transfer) {
      vti.vtt!.outputs.forEach((element) {
        if ((externalAddresses.contains(element.pkh.address) ||
            internalAddresses.contains(element.pkh.address))) {
          nanoWitvalue += element.value.toInt();
        } else if (singleAddressAccount != null &&
            singleAddressAccount!.address == element.pkh.address) {
          nanoWitvalue += element.value.toInt();
        }
      });
      return nanoWitvalue;
    } else {
      vti.mint!.outputs.forEach((element) {
        if ((externalAddresses.contains(element.pkh.address) ||
            internalAddresses.contains(element.pkh.address))) {
          nanoWitvalue += element.value.toInt();
        } else if (singleAddressAccount != null &&
            singleAddressAccount!.address == element.pkh.address) {
          nanoWitvalue += element.value.toInt();
        }
      });
      return nanoWitvalue;
    }
  }

  int sendValue(GeneralTransaction vti) {
    if (vti.txnType == TransactionType.value_transfer) {
      bool isInternalTx =
          externalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
              internalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
              singleAddressAccount?.address == vti.vtt!.outputs[0].pkh.address;
      return isInternalTx ? vti.fee : vti.vtt!.outputs[0].value.toInt();
    } else {
      return 0;
    }
  }

  Widget buildTransactionValue(label, transaction) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    if (label == localization.from) {
      return Text(
        ' + ${receiveValue(transaction).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: extendedTheme.txValuePositiveColor),
        overflow: TextOverflow.ellipsis,
      );
    } else if (sendValue(transaction).standardizeWitUnits().toString() != '0') {
      return Text(
        ' - ${sendValue(transaction).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: extendedTheme.txValueNegativeColor),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '${sendValue(transaction).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  Widget buildTransactionStatus(ThemeData theme) {
    String transactionStatus = widget.transaction.status;
    String localizedtxnStatus = localization.txnStatus(transactionStatus);
    String txnTime = widget.transaction.txnTime.formatDuration(context);
    List<Widget> pendingStatus = [];
    String transacionStatusCopy = txnTime;

    if (transactionStatus != "confirmed") {
      transacionStatusCopy = "$localizedtxnStatus $txnTime";
      if (transactionStatus == "pending") {
        pendingStatus = [
          Icon(FontAwesomeIcons.clock,
              size: 10, color: theme.textTheme.bodySmall!.color),
          SizedBox(width: 4)
        ];
      }
    }

    return Row(
      children: [
        ...pendingStatus,
        Text(
          transacionStatusCopy,
          textAlign: TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    String label;
    String address;
    TransactionType txnType = widget.transaction.txnType;

    if (txnType == TransactionType.value_transfer) {
      label = getTransactionLabel(externalAddresses, internalAddresses,
          widget.transaction.vtt!.inputs, singleAddressAccount, context);
      address = getTransactionAddress(label, widget.transaction.vtt!.inputs,
          widget.transaction.vtt!.outputs);
    } else {
      label = localization.from;
      address = 'Mint';
    }

    return Semantics(
        button: true,
        enabled: true,
        label: localization.transaction,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTransactionStatus(theme),
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: WitnetPallet.transparent,
                        border: Border(
                            bottom: BorderSide(
                          color: extendedTheme.txBorderColor!,
                          width: 0.5,
                        )),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  buildTransactionValue(
                                      label, widget.transaction),
                                ])),
                            SizedBox(
                              width: 8,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  label.capitalize(),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  address,
                                  overflow: TextOverflow.fade,
                                  style: extendedTheme.monoSmallText!.copyWith(
                                      color: theme.textTheme.bodyMedium!.color),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
            onTap: () {
              widget.showDetails(widget.transaction);
            },
          ),
        ));
  }
}
