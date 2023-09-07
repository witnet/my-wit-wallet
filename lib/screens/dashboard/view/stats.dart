import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/create_wallet/nav_action.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/util/extensions/num_extensions.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:my_wit_wallet/widgets/info_element.dart';

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
    return Padding(
        padding: EdgeInsets.only(left: 12, right: 8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              InfoElement(
                  label: 'Data Requests solved',
                  text: stats?.totalDrSolved.toString() ?? '0'),
              InfoElement(
                  label: 'Blocks mined',
                  text: stats?.totalBlocksMined.toString() ?? '0'),
              InfoElement(
                  label: 'Total fees payed',
                  text:
                      '${(stats?.totalFeesPayed ?? 0).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
              InfoElement(
                  label: 'Total mining rewards',
                  isLastItem: true,
                  text:
                      '${(stats?.totalRewards ?? 0).standardizeWitUnits().formatWithCommaSeparator()} ${WIT_UNIT[WitUnit.Wit]}'),
            ]));
  }
}
