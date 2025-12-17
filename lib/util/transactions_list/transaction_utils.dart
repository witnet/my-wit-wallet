import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:my_wit_wallet/theme/extended_theme.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/metadata_utils.dart';
import 'package:my_wit_wallet/util/storage/database/account.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/extensions/string_extensions.dart';
import 'package:my_wit_wallet/util/transactions_list/get_transaction_label.dart';
import 'package:my_wit_wallet/util/extensions/int_extensions.dart';
import 'package:witnet/explorer.dart';

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
    int currentTimelockSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    switch (vti.type) {
      case TransactionType.value_transfer:
        vti.vtt!.outputs.forEach((element) {
          if (element.timeLock > currentTimelockSeconds) {
            amountLocked += element.value.toInt();
          }
        });
        return amountLocked;
      case TransactionType.data_request:
        // TODO: add data request inputs
        return amountLocked;
      case TransactionType.mint:
        // There is no timelock
        return amountLocked;
      case TransactionType.stake:
        if (vti.stake!.change != null &&
            vti.stake!.change!.timeLock > currentTimelockSeconds) {
          amountLocked = vti.stake!.value;
        }
        return amountLocked;
      case TransactionType.unstake:
        int unstakeTimelock =
            vti.unstake!.timestamp.toInt() + UNSTAKE_DELAY_SECONDS;
        if (unstakeTimelock > currentTimelockSeconds) {
          amountLocked = vti.unstake!.value;
        }
        return amountLocked;
    }
  }

  String? timelock() {
    String? timelock = null;
    int currentTimelockSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    switch (vti.type) {
      case TransactionType.value_transfer:
        vti.vtt!.outputs.forEach((element) {
          if (element.timeLock > currentTimelockSeconds) {
            timelock = element.timeLock.toInt().formatDate();
          }
        });
        return timelock;
      case TransactionType.data_request:
        // TODO: add data request inputs
        return timelock;
      case TransactionType.mint:
        return timelock;
      case TransactionType.stake:
        if (vti.stake!.change != null &&
            vti.stake!.change!.timeLock > currentTimelockSeconds) {
          timelock = vti.stake!.change?.timeLock.toInt().formatDate();
        }
        return timelock;
      case TransactionType.unstake:
        int unstakeTimelock =
            vti.unstake!.timestamp.toInt() + UNSTAKE_DELAY_SECONDS;
        if (unstakeTimelock > currentTimelockSeconds) {
          timelock = (unstakeTimelock).formatDate();
        }
        return timelock;
    }
  }

  int receiveValue() {
    int nanoWitvalue = 0;
    switch (vti.type) {
      case TransactionType.value_transfer:
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
      case TransactionType.data_request:
        // TODO: add data request receiveValue
        return nanoWitvalue;
      case TransactionType.mint:
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
      case TransactionType.stake:
        nanoWitvalue += vti.stake!.value;
        return nanoWitvalue;
      case TransactionType.unstake:
        nanoWitvalue += vti.unstake!.value;
        return nanoWitvalue;
    }
  }

  int sendValue() {
    switch (vti.type) {
      case TransactionType.value_transfer:
        if (vti.vtt!.outputs.length <= 0) {
          return 0;
        }
        bool isInternalTx = externalAddresses
                .contains(vti.vtt!.outputs[0].pkh.address) ||
            internalAddresses.contains(vti.vtt!.outputs[0].pkh.address) ||
            singleAddressAccount?.address == vti.vtt!.outputs[0].pkh.address;
        return isInternalTx ? vti.fee : vti.vtt!.outputs[0].value.toInt();
      case TransactionType.data_request:
        // TODO: add data request sendValue
        return 0;
      case TransactionType.mint:
        return vti.mint!.outputs[0].value.toInt();
      case TransactionType.stake:
        return vti.stake!.value;
      case TransactionType.unstake:
        return vti.unstake!.value;
    }
  }

  List<String?> getInputsAddresses(TransactionType type) {
    switch (type) {
      case TransactionType.value_transfer:
        return vti.vtt!.inputs.map((InputUtxo input) => input.address).toList();
      case TransactionType.data_request:
        // TODO: add data request inputs
        return [];
      case TransactionType.mint:
        return [];
      case TransactionType.stake:
        return vti.stake!.inputs
            .map((StakeInput input) => input.address)
            .toList();
      case TransactionType.unstake:
        return [vti.unstake!.validator];
    }
  }

  String getLabel() {
    return getTransactionLabel(
      inputsAddresses: getInputsAddresses(vti.type),
      externalAddresses: externalAddresses,
      internalAddresses: internalAddresses,
      singleAddressAccount: singleAddressAccount,
    );
  }

  String getMainTxInfo() {
    String address = '';
    String label = getLabel();
    switch (vti.type) {
      case TransactionType.value_transfer:
        if (vti.vtt != null && vti.vtt!.inputs.isEmpty) return 'genesis';
        if (label == localization.from && vti.vtt!.inputs.length > 0) {
          address = getSenderAddress().cropMiddle(18);
        } else if (vti.vtt!.outputs.length > 0) {
          address = getRecipientAddress().cropMiddle(18);
        }
        return address;
      case TransactionType.data_request:
        return 'DR';
      case TransactionType.mint:
        return 'Mint';
      case TransactionType.stake:
        return 'Stake';
      case TransactionType.unstake:
        return 'Unstake';
    }
  }

  String getSenderAddress() {
    switch (vti.type) {
      case TransactionType.value_transfer:
        return vti.vtt!.inputs[0].address;
      case TransactionType.data_request:
        return 'DR';
      case TransactionType.mint:
        return 'Mint';
      case TransactionType.stake:
        return vti.stake!.inputs[0].address;
      case TransactionType.unstake:
        return 'Unstake';
    }
  }

  String getWithdrawalAddress() {
    switch (vti.type) {
      case TransactionType.value_transfer:
        return '';
      case TransactionType.data_request:
        return '';
      case TransactionType.mint:
        return '';
      case TransactionType.stake:
        return vti.stake!.withdrawer;
      case TransactionType.unstake:
        return vti.unstake!.withdrawer;
    }
  }

  String getValidatorAddress() {
    switch (vti.type) {
      case TransactionType.value_transfer:
        return '';
      case TransactionType.data_request:
        return '';
      case TransactionType.mint:
        return '';
      case TransactionType.stake:
        return vti.stake!.validator;
      case TransactionType.unstake:
        return vti.unstake!.validator;
    }
  }

  String getRecipientAddress() {
    switch (vti.type) {
      case TransactionType.value_transfer:
        return vti.vtt!.outputs[0].pkh.address;
      case TransactionType.data_request:
        return 'DR';
      case TransactionType.mint:
        return vti.mint!.outputs[0].pkh.address;
      case TransactionType.stake:
        return 'Stake';
      case TransactionType.unstake:
        return vti.unstake!.withdrawer;
    }
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

  String? metadata() {
    if (vti.type != TransactionType.value_transfer || vti.vtt == null) {
      return null;
    }

    return metadataFromOutputs(vti.vtt!.outputs);
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
