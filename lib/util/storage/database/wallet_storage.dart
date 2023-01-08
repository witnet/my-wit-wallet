import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet_wallet/util/storage/database/wallet.dart';

import 'account.dart';
import 'balance_info.dart';

final defaultWallet = Wallet(
    name: '',
    description: '',
    xprv: '',
    externalXpub: '',
    internalXpub: '',
    txHashes: [],
    externalAccounts: {},
    internalAccounts: {},
    lastSynced: -1);
final defaultAccount = Account(
    address: '',
    walletName: '',
    path: '');

final defaulVtt = ValueTransferInfo(
    blockHash: '0000000000000000000000000000000000000000000000000000000000000000',
    fee: 0,
    inputs: [],
    outputs: [],
    priority: 0,
    status: 'pending',
    txnEpoch: 0,
    txnHash: '0000000000000000000000000000000000000000000000000000000000000000',
    txnTime: 0,
    type: 'valueTransfer',
    weight: 0
);
/// DbWallet formats the wallet for the database
class WalletStorage {

  WalletStorage({
    required this.wallets,
  });
  // <wallet_id, Wallet>
  Map<String, Wallet> wallets;
  // <address, Account>
  late Map<String, Account> _accounts;
  // <transactionId, ValueTransferInfo>
  late Map<String, ValueTransferInfo> _transactions;

  String? _currentWalletId;
  String? _currentAddress;
  Map<String, String>? currentAddressList;
  Wallet get currentWallet => wallets[_currentWalletId]!;


  void setCurrentWallet(String walletId){
    _currentWalletId = walletId;
  }

  void setCurrentAccount(String address){
    _currentAddress = address;
  }
  void setCurrentAddressList(Map<String, String> addressList){
    currentAddressList = addressList;
  }

  void setTransactions(Map<String, ValueTransferInfo> transactions) {
    _transactions = transactions;
  }

  void setAccounts(Map<String, Account> accounts) {
    _accounts = accounts;
  }

  Account get currentAccount => _accounts[_currentAddress] ?? defaultAccount;

  Account getAccount(String address) {
    Account? _account;
    wallets.values.forEach((wallet) {
      wallet.internalAccounts.values.forEach((account) {
        if(account.address == address){
          _account = account;
        }
      });
      wallet.externalAccounts.values.forEach((account) {
        if(account.address == address){
          _account = account;
        }
      });
    });

    return _account ?? defaultAccount;
  }
  ValueTransferInfo getVtt(String hash) => _transactions[hash] ?? defaulVtt;

  void setAccount(Account account){
    _accounts[account.address] = account;
    wallets[account.walletId]!.setAccount(account);
  }
  BalanceInfo balanceNanoWit() {
    BalanceInfo balance = BalanceInfo(availableUtxos: [], lockedUtxos: []);
    wallets.forEach((key, value) {
      balance += value.balanceNanoWit();
    });
    return balance;
  }
}
