import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/container_background.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';
import 'package:my_wit_wallet/util/get_localization.dart';

typedef void VoidCallback(NavAction? value);

class Stats extends StatefulWidget {
  final Wallet currentWallet;
  Stats({
    Key? key,
    required this.currentWallet,
  }) : super(key: key);

  BlockStatsState createState() => BlockStatsState();
}

class BlockStatsState extends State<Stats> with TickerProviderStateMixin {
  dynamic blocks;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AccountStats? stats = widget.currentWallet.masterAccountStats;
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text(localization.networkContribution,
              style: theme.textTheme.titleMedium),
          SizedBox(height: 8),
          ContainerBackground(
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                InfoElement(
                    isContentImportant: true,
                    label: localization.drSolved,
                    text: stats?.totalDrSolved.toString() ?? '0'),
                InfoElement(
                    isContentImportant: true,
                    label: localization.blocksMined,
                    isLastItem: true,
                    text: stats?.totalBlocksMined.toString() ?? '0'),
              ])),
          SizedBox(height: 16),
          Text(localization.feesAndRewards, style: theme.textTheme.titleMedium),
          SizedBox(height: 8),
          ContainerBackground(
              content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                InfoElement(
                    isContentImportant: true,
                    label: localization.totalFeesPaid,
                    text:
                        '${(stats?.totalFeesPayed ?? 0).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
                InfoElement(
                    isContentImportant: true,
                    label: localization.totalMiningRewards,
                    isLastItem: true,
                    text:
                        '${(stats?.totalRewards ?? 0).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
              ]))
        ]);
  }
}
