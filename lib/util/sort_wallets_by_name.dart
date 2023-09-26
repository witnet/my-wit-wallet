import 'package:my_wit_wallet/widgets/wallet_list.dart';

List<WalletIdName> sortWalletListByName(List<WalletIdName> walletIdList) {
  return walletIdList..sort((a, b) => a.name.compareTo(b.name));
}
