import 'dart:core';

import 'package:equatable/equatable.dart';

enum MasterAccountStats {
  blocks,
  details,
  data_requests_solved,
  data_requests_launched,
  value_transfers,
}

class AccountStats extends Equatable {
  final String address;
  final String walletId;
  final int totalBlocksMined;
  final int totalFeesPayed;
  final int totalRewards;
  final int totalDrSolved;

  AccountStats(
      {required this.address,
      required this.walletId,
      required this.totalBlocksMined,
      required this.totalFeesPayed,
      required this.totalRewards,
      required this.totalDrSolved});

  @override
  List<Object?> get props => [
        address,
        walletId,
        totalBlocksMined,
        totalFeesPayed,
        totalRewards,
        totalDrSolved
      ];

  factory AccountStats.fromJson(Map<String, dynamic> data) {
    AccountStats account = AccountStats(
      walletId: data['walletId'],
      address: data['address'],
      totalBlocksMined: data['totalBlocksMined'],
      totalFeesPayed: data['totalFeesPayed'],
      totalRewards: data['totalRewards'],
      totalDrSolved: data['totalDrSolved'],
    );
    return account;
  }

  Map<String, dynamic> jsonMap() {
    return {
      'walletId': walletId,
      'address': address,
      'totalBlocksMined': totalBlocksMined,
      'totalFeesPayed': totalFeesPayed,
      'totalRewards': totalRewards,
      'totalDrSolved': totalDrSolved,
    };
  }
}
