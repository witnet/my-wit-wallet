import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/get_localization.dart';
import 'package:my_wit_wallet/util/storage/database/balance_info.dart';
import 'package:flutter/material.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';

typedef void VoidCallback();

class BalanceDetails extends StatelessWidget {
  BalanceDetails({required this.balance, required this.stakedBalance});
  final BalanceInfo balance;
  final StakedBalanceInfo stakedBalance;

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
        padding: EdgeInsets.only(top: 32, bottom: 32, left: 24, right: 24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.balanceDetails,
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: 24),
              InfoElement(
                isContentImportant: true,
                label: localization.available,
                text:
                    '${balance.availableNanoWit.standardizeWitUnits().toString()} ${WIT_UNIT[WitUnit.Wit]}',
              ),
              InfoElement(
                isContentImportant: true,
                label: localization.locked,
                text:
                    '${balance.lockedNanoWit.standardizeWitUnits().toString()} ${WIT_UNIT[WitUnit.Wit]}',
              ),
              InfoElement(
                isContentImportant: true,
                label: localization.staked,
                text:
                    '${stakedBalance.stakedNanoWit.standardizeWitUnits().toString()} ${WIT_UNIT[WitUnit.Wit]}',
              ),
            ]));
  }
}
