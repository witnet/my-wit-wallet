import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_label.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/schema.dart';

class TransactionValue {
  final String label;
  final String prefix;
  final String amount;
  TransactionValue(
      {required this.label, required this.prefix, required this.amount});
}

class TransactionUtils {
  Wallet currentWallet =
      Locator.instance.get<ApiDatabase>().walletStorage.currentWallet;

  final GeneralTransaction vti;
  TransactionUtils({required this.vti});

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

  int lockedValue() {
    int amountLocked = 0;
    if (vti.type == TransactionType.value_transfer) {
      vti.vtt!.outputs.forEach((element) {
        if (element.timeLock > DateTime.now().millisecondsSinceEpoch ~/ 1000) {
          amountLocked += element.value.toInt();
        }
      });
    }
    return amountLocked;
  }

  String? timelock() {
    String? timelock = null;
    if (vti.type == TransactionType.value_transfer) {
      vti.vtt!.outputs.forEach((element) {
        if (element.timeLock > DateTime.now().millisecondsSinceEpoch ~/ 1000) {
          timelock = element.timeLock.toInt().formatDate();
        }
      });
    }
    return timelock;
  }

  int receiveValue() {
    int nanoWitvalue = 0;
    if (vti.type == TransactionType.value_transfer) {
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
    } else if (vti.mint != null) {
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
    } else if (vti.stake != null) {
      // TODO(#542): get value and correct type for for stake transactions
      vti.stake!.outputs.forEach((element) {
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
      // TODO(#542): get value and correct type for unstake transactions
      vti.unstake!.outputs.forEach((element) {
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

  int sendValue() {
    if (vti.type != TransactionType.value_transfer ||
        vti.vtt!.outputs.length <= 0) {
      return 0;
    }
    bool isInternalTx =
        externalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
            internalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
            singleAddressAccount?.address == vti.vtt!.outputs[0].pkh.address;
    return isInternalTx ? vti.fee : vti.vtt!.outputs[0].value.toInt();
  }

  String getLabel() {
    if (vti.type == TransactionType.value_transfer) {
      return getTransactionLabel(
          externalAddresses: externalAddresses,
          internalAddresses: internalAddresses,
          inputs: vti.vtt!.inputs,
          singleAddressAccount: singleAddressAccount);
    } else {
      // TODO(#542): set stake and unstake transaction label when feature is supported
      return localization.from;
    }
  }

  String getOrigin() {
    if (vti.type == TransactionType.value_transfer) {
      return getTransactionAddress(
          getLabel(), vti.vtt!.inputs, vti.vtt!.outputs);
    } else {
      // TODO(#542): set stake and unstake transaction label when feature is supported
      return 'Mint';
    }
  }

  String getTransactionAddress(
      String label, List<InputUtxo> inputs, List<ValueTransferOutput> outputs) {
    String address = '';
    if (inputs.length < 1)
      return 'genesis';
    else if (label == localization.from && inputs.length > 0) {
      address = getSenderAddress().cropMiddle(18);
    } else if (outputs.length > 0) {
      address = getRecipientAddress().cropMiddle(18);
    }
    return address;
  }

  String getSenderAddress() {
    return vti.vtt!.inputs[0].address;
  }

  String getRecipientAddress() {
    return vti.vtt!.outputs[0].pkh.address;
  }

  TransactionValue getTransactionValue() {
    String _label = getLabel();
    if (_label == localization.from) {
      return TransactionValue(
        label: _label,
        prefix: '+',
        amount:
            '${receiveValue().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
      );
    } else if (sendValue().standardizeWitUnits().toString() != '0') {
      return TransactionValue(
        label: _label,
        prefix: '-',
        amount:
            '${sendValue().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
      );
    } else {
      return TransactionValue(
        label: _label,
        prefix: '',
        amount:
            '${sendValue().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
      );
    }
  }

  Widget buildTransactionValue(label, context) {
    final theme = Theme.of(context);
    final extendedTheme = theme.extension<ExtendedTheme>()!;
    int _lockedWit = lockedValue();
    if (label == localization.from) {
      return Text(
        ' + ${receiveValue().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyMedium?.copyWith(
            color: _lockedWit > 0
                ? WitnetPallet.mediumGrey
                : extendedTheme.txValuePositiveColor),
        overflow: TextOverflow.ellipsis,
      );
    } else if (sendValue().standardizeWitUnits().toString() != '0') {
      return Text(
        ' - ${sendValue().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyMedium?.copyWith(
            color: _lockedWit > 0
                ? WitnetPallet.mediumGrey
                : extendedTheme.txValueNegativeColor),
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return Text(
        '${sendValue().standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}',
        style: theme.textTheme.bodyMedium!.copyWith(
            color: _lockedWit > 0
                ? WitnetPallet.mediumGrey
                : theme.textTheme.bodyMedium!.color),
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
