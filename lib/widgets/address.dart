import 'package:witnet_wallet/util/storage/database/balance_info.dart';

class Address {
  String address;
  int index;
  BalanceInfo balance;

  Address({
    required this.address,
    required this.balance,
    required this.index,
  });
}
