import 'package:my_wit_wallet/util/sort_wallets_by_name.dart';
import 'package:my_wit_wallet/widgets/wallet_list.dart';
import 'package:test/test.dart';

void main() async {
  test('Sort wallets by name', () async {
    List<WalletIdName> walletList = [
      WalletIdName(id: 'a', name: 'd'),
      WalletIdName(id: 'b', name: 'c'),
      WalletIdName(id: 'c', name: 'b'),
      WalletIdName(id: 'd', name: 'a'),
    ];
    List<WalletIdName> sortedWalletList = [
      WalletIdName(id: 'd', name: 'a'),
      WalletIdName(id: 'c', name: 'b'),
      WalletIdName(id: 'b', name: 'c'),
      WalletIdName(id: 'a', name: 'd'),
    ];

    expect(sortWalletListByName(walletList)[0].name, sortedWalletList[0].name);
    expect(sortWalletListByName(walletList)[1].name, sortedWalletList[1].name);
    expect(sortWalletListByName(walletList)[2].name, sortedWalletList[2].name);
    expect(sortWalletListByName(walletList)[3].name, sortedWalletList[3].name);
  });
}
