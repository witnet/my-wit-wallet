import 'package:flutter/material.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

typedef String LocalizationCallback(String value);

Map<Enum, String> localizeEnum<T extends Enum>(
  BuildContext context,
  List<T> enumValues,
  LocalizationCallback callback,
) =>
    Map<Enum, String>.fromIterable(
      enumValues,
      key: (item) => item,
      value: (item) => callback("${item.index}"),
    );

Map<WalletType, String> walletTypeToLabel(BuildContext context) => {
      WalletType.hd: AppLocalizations.of(context)!.walletTypeHDLabel,
      WalletType.single: AppLocalizations.of(context)!.walletTypeNodeLabel,
    };
