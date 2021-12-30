import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'auto_size_text.dart';

class SolvedDrCard extends StatelessWidget {
  final int collateral;
  final int receivedValue;
  final int reward;
  final String reveal;
  final String tally;
  final bool error;
  final bool outOfConsensus;
  final int epoch;
  SolvedDrCard({
    required this.reveal,
    required this.tally,
    required this.error,
    required this.outOfConsensus,
    required this.collateral,
    required this.receivedValue,
    required this.reward,
    required this.epoch,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    AutoSizeText(
                      'Epoch: $epoch',
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                    AutoSizeText(
                      'Collateral: $collateral',
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                    AutoSizeText(
                      'Reward: $reward',
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                    AutoSizeText(
                      'Reveal: $reveal',
                      maxLines: 1,
                      minFontSize: 9,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          FontAwesomeIcons.sync,
                          size: 15,
                        )),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
