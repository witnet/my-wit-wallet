import 'package:witnet/explorer.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

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
final defaultAccount = Account(address: '', walletName: '', path: '');

final defaulVtt = ValueTransferInfo(
    blockHash:
        '0000000000000000000000000000000000000000000000000000000000000000',
    fee: 0,
    inputs: [],
    outputs: [],
    priority: 0,
    status: 'pending',
    txnEpoch: 0,
    txnHash: '0000000000000000000000000000000000000000000000000000000000000000',
    txnTime: 0,
    type: 'valueTransfer',
    weight: 0);

/// DbWallet formats the wallet for the database
class WalletStorage {
  WalletStorage({
    required this.wallets,
  });
  // <wallet_id, Wallet>
  Map<String, Wallet> wallets;
  // <address, Account>
  Map<String, Account> _accounts = {};
  // <transactionId, ValueTransferInfo>
  Map<String, ValueTransferInfo> _transactions = {};

  String? _currentWalletId;
  String? _currentAddress;
  Map<String, dynamic>? currentAddressList;
  Wallet get currentWallet => wallets[_currentWalletId] != null
      ? wallets[_currentWalletId]!
      : wallets[wallets.keys.first]!;

  void setCurrentWallet(String walletId) {
    _currentWalletId = walletId;
  }

  void setCurrentAccount(String address) {
    _currentAddress = address;
  }

  void setCurrentAddressList(Map<String, dynamic> addressList) {
    currentAddressList = addressList;
  }

  void setTransactions(Map<String, ValueTransferInfo> transactions) {
    transactions.forEach((transactionId, vtt) {
      _transactions[transactionId] = vtt;
    });
  }

  void setAccounts(Map<String, Account> accounts) {
    accounts.values.forEach((account) {
      setAccount(account);
    });
  }

  Account get currentAccount => _accounts[_currentAddress] ?? defaultAccount;

  Account getAccount(String address) {
    Account? _account;
    wallets.values.forEach((wallet) {
      wallet.internalAccounts.values.forEach((account) {
        if (account.address == address) {
          _account = account;
        }
      });
      wallet.externalAccounts.values.forEach((account) {
        if (account.address == address) {
          _account = account;
        }
      });
    });

    return _account ?? defaultAccount;
  }

  ValueTransferInfo? getVtt(String hash) => _transactions[hash];

  void setVtt(String walletId, ValueTransferInfo vtt) {
    wallets[walletId]!.setTransaction(vtt);
  }

  void setAccount(Account account) {
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
