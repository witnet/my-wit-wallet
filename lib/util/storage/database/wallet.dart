import 'dart:core';

import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/stats.dart';
import 'package:my_wit_wallet/util/storage/database/adapters/transaction_adapter.dart';
import 'package:my_wit_wallet/util/storage/database/wallet_storage.dart';
import 'package:witnet/constants.dart';
import 'package:witnet/crypto.dart';
import 'package:witnet/data_structures.dart';
import 'package:witnet/explorer.dart';
import 'package:witnet/utils.dart';
import 'package:witnet/witnet.dart';

import 'account.dart';
import 'balance_info.dart';

enum KeyType { internal, external, master }

class PaginatedData {
  final int totalPages;
  final List<GeneralTransaction> data;

  PaginatedData({required this.totalPages, required this.data});
}

enum WalletType {
  unknown,
  hd,
  single,
}

class Wallet {
  Wallet({
    required this.walletType,
    required this.name,
    this.xprv,
    this.externalXpub,
    this.internalXpub,
    required this.txHashes,
    required this.masterAccount,
    required this.masterAccountStats,
    required this.externalAccounts,
    required this.internalAccounts,
    this.lastSynced = -1,
  }) {
    this.id = '00000000';
    this.externalAccounts.forEach((key, Account account) {
      account.balance;
    });

    this.internalAccounts.forEach((key, Account account) {
      account.balance;
    });
  }

  final WalletType walletType;
  late String id;
  final String name;
  late List<String?> txHashes;
  late String? xprv;
  late String? externalXpub;
  late String? internalXpub;
  AccountStats? masterAccountStats;

  late Xpub _internalXpub;
  late Xpub _externalXpub;

  final Map<int, Xpub> externalKeys = {};
  final Map<int, Xpub> internalKeys = {};
  int lastSynced;

  Map<int, Account> externalAccounts = {};
  Map<int, Account> internalAccounts = {};
  Account? masterAccount;

  Map<String, Account> accountMap(KeyType keyType) {
    Map<String, Account> _accounts = {};
    switch (keyType) {
      case KeyType.internal:
        orderAccountsByIndex(internalAccounts).forEach((index, account) {
          _accounts[account.address] = account;
        });
        break;
      case KeyType.external:
        orderAccountsByIndex(externalAccounts).forEach((index, account) {
          _accounts[account.address] = account;
        });
        break;
      case KeyType.master:
        _accounts[masterAccount!.address] = masterAccount!;
        break;
    }
    return _accounts;
  }

  Future<void> deleteVtt(Wallet wallet, ValueTransferInfo vtt) async {
    /// check the inputs for accounts in the wallet and remove the vtt
    for (int i = 0; i < vtt.inputAddresses.length; i++) {
      Account? account = wallet.accountByAddress(vtt.inputAddresses[i]);
      if (account != null) {
        await account.deleteVtt(vtt);
      }
    }

    /// check the outputs for accounts in the wallet and remove the vtt
    for (int i = 0; i < vtt.outputAddresses.length; i++) {
      Account? account = wallet.accountByAddress(vtt.outputAddresses[i]);
      if (account != null) {
        await account.deleteVtt(vtt);
      }
    }
  }

  Map<int, Account> orderAccountsByIndex(Map<int, Account> accountMap) {
    return Map.fromEntries(accountMap.entries.toList()
      ..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  List<String> addressList(KeyType keyType) {
    List<String> addresses = [];
    if (keyType == KeyType.external) {
      addresses.addAll(Iterable<String>.generate(
          externalAccounts.length, (i) => externalAccounts[i]!.address));
    } else {
      addresses.addAll(Iterable<String>.generate(
          internalAccounts.length, (i) => internalAccounts[i]!.address));
    }
    return addresses;
  }

  List<String> allAddresses() {
    List<String> _addresses = [];
    if (walletType == WalletType.hd) {
      _addresses.addAll(addressList(KeyType.external));
      _addresses.addAll(addressList(KeyType.internal));
    } else if (walletType == WalletType.single) {
      _addresses.add(masterAccount!.address);
    }

    return _addresses;
  }

  Map<String, Account> orderedExternalAccounts() {
    return accountMap(KeyType.external);
  }

  Map<String, Account> allAccounts() {
    Map<String, Account> _accounts = {};
    _accounts.addAll(accountMap(KeyType.external));
    _accounts.addAll(accountMap(KeyType.internal));
    if (masterAccount != null) _accounts.addAll(accountMap(KeyType.master));
    return _accounts;
  }

  List<MintEntry> allMints() {
    List<MintEntry> allMints = [];
    if (walletType == WalletType.single && masterAccount!.mints.length > 0) {
      masterAccount!.mints.forEach((MintEntry mint) {
        if (mint.status != TxStatusLabel.reverted &&
            mint.status != TxStatusLabel.unknown) allMints.add(mint);
      });
      return allMints;
    } else {
      return [];
    }
  }

  List<ValueTransferInfo> unconfirmedTransactions() {
    List<ValueTransferInfo> unconfirmedVtts = [];
    allTransactions().forEach((vtt) {
      if (vtt.status != TxStatusLabel.confirmed) {
        unconfirmedVtts.add(vtt);
      }
    });
    return unconfirmedVtts;
  }

  List<ValueTransferInfo> pendingTransactions() {
    List<ValueTransferInfo> pendingVtts = [];
    allTransactions().forEach((vtt) {
      if (vtt.status == TxStatusLabel.pending) {
        pendingVtts.add(vtt);
      }
    });
    return pendingVtts;
  }

  List<ValueTransferInfo> allTransactions() {
    Map<String, ValueTransferInfo> _vttMap = {};
    externalAccounts.forEach((key, account) {
      account.vtts.forEach((vtt) {
        if (vtt.status != TxStatusLabel.reverted) _vttMap[vtt.hash] = vtt;
      });
    });
    internalAccounts.forEach((key, account) {
      account.vtts.forEach((vtt) {
        if (vtt.status != TxStatusLabel.reverted) _vttMap[vtt.hash] = vtt;
      });
    });

    if (walletType == WalletType.single) {
      masterAccount!.vtts.forEach((vtt) {
        if (vtt.status != TxStatusLabel.reverted) _vttMap[vtt.hash] = vtt;
      });
    }
    return _vttMap.values.toList()
      ..sort((t1, t2) => t2.txnTime.compareTo(t1.txnTime));
  }

  PaginatedData getPaginatedTransactions(PaginationParams args) {
    List<ValueTransferInfo> vtts = allTransactions();
    List<MintEntry> mints = allMints();
    List<GeneralTransaction> standardizeVtts = vtts
        .map((ValueTransferInfo vtt) =>
            GeneralTransaction.fromValueTransferInfo(vtt))
        .toList();
    List<GeneralTransaction> standardizeMints = mints
        .map((MintEntry mint) => GeneralTransaction.fromMintEntry(mint))
        .toList();
    List<GeneralTransaction> allSortedTransactions = [
      ...standardizeVtts,
      ...standardizeMints
    ]..sort((GeneralTransaction t1, GeneralTransaction t2) =>
        t2.txnTime.compareTo(t1.txnTime));
    if (allSortedTransactions.length > 0) {
      final totalPages = (allSortedTransactions.length / args.limit).ceil();
      int offset = (args.currentPage - 1) * args.limit;
      int pageEndPosition = args.currentPage >= totalPages
          ? allSortedTransactions.length
          : (offset + args.limit);
      List<GeneralTransaction> pageData =
          allSortedTransactions.sublist(offset, pageEndPosition);
      return PaginatedData(totalPages: totalPages, data: pageData);
    } else {
      return PaginatedData(totalPages: 0, data: []);
    }
  }

  Account? accountByAddress(String address) {
    List<Account> _accounts = allAccounts().values.toList();

    try {
      _accounts.retainWhere((element) => element.address == address);
      return _accounts[0];
    } catch (e) {
      return null;
    }
  }

  static Future<Wallet> fromMnemonic({
    required WalletType walletType,
    required String name,
    required String mnemonic,
    required String password,
  }) async {
    final _wallet = Wallet(
      walletType: walletType,
      name: name,
      txHashes: [],
      externalAccounts: {},
      internalAccounts: {},
      masterAccount: null,
      masterAccountStats: null,
    );
    _wallet._setMasterXprv(Xprv.fromMnemonic(mnemonic: mnemonic), password);
    return _wallet;
  }

  static Future<Wallet> fromXprvStr({
    required WalletType walletType,
    required String name,
    required String xprv,
    required String password,
  }) async {
    final _wallet = Wallet(
      walletType: walletType,
      name: name,
      xprv: xprv,
      txHashes: [],
      externalAccounts: {},
      internalAccounts: {},
      masterAccount: null,
      masterAccountStats: null,
    );
    _wallet._setMasterXprv(Xprv.fromXprv(xprv), password);
    return _wallet;
  }

  static Future<Wallet> fromEncryptedXprv({
    required WalletType walletType,
    required String name,
    required String xprv,
    required String password,
  }) async {
    try {
      final _wallet = Wallet(
        walletType: walletType,
        name: name,
        xprv: xprv,
        txHashes: [],
        externalAccounts: {},
        internalAccounts: {},
        masterAccount: null,
        masterAccountStats: null,
      );
      _wallet._setMasterXprv(Xprv.fromEncryptedXprv(xprv, password), password);
      return _wallet;
    } catch (e) {
      rethrow;
    }
  }

  void _setMasterXprv(Xprv xprv, String password) {
    Xprv walletXprv =
        xprv / KEYPATH_PURPOSE / KEYPATH_COIN_TYPE / KEYPATH_ACCOUNT;
    Xprv externalXprv = walletXprv / 0;
    Xprv internalXprv = walletXprv / 1;
    this.xprv = xprv.toEncryptedXprv(password: password);
    _internalXpub = internalXprv.toXpub();
    _externalXpub = externalXprv.toXpub();

    this.internalXpub = _internalXpub.toSlip32();
    this.externalXpub = _externalXpub.toSlip32();

    /// The Wallet ID is the first 4 bytes of the sha256 hash of the Extended Public Key.
    this.id = bytesToHex(sha256(data: Xpub.fromXpub(externalXpub!).key))
        .substring(0, 8);
    if (walletType == WalletType.single) {
      this.masterAccount = Account(
          walletName: name, address: xprv.address.address, path: xprv.rootPath);
      this.masterAccount!.walletId = this.id;
    }
  }

  void addAccount({
    required Account account,
    required int index,
    required KeyType keyType,
  }) {
    switch (keyType) {
      case KeyType.internal:
        internalAccounts[index] = account;
        break;
      case KeyType.external:
        externalAccounts[index] = account;
        break;
      case KeyType.master:
        masterAccount = account;
        break;
    }
  }

  BalanceInfo balanceNanoWit() {
    List<Utxo> _utxos = [];

    internalAccounts.forEach((address, account) {
      _utxos.addAll(account.utxos);
    });
    externalAccounts.forEach((address, account) {
      _utxos.addAll(account.utxos);
    });
    if (masterAccount != null) {
      _utxos.addAll(masterAccount!.utxos);
    }
    return BalanceInfo.fromUtxoList(_utxos);
  }

  Future<Account> generateKey({
    required int index,
    KeyType keyType = KeyType.external,
  }) async {
    // send the request
    Xpub xpub = await Locator.instance<CryptoIsolate>()
        .send(method: 'generateKey', params: {
      'external_keychain': externalXpub,
      'internal_keychain': internalXpub,
      'index': index,
      'keyType': keyType.name
    });
    Account _account =
        Account(walletName: name, address: xpub.address, path: xpub.path!);
    _account.walletId = id;
    switch (keyType) {
      case KeyType.internal:
        {
          internalAccounts[index] = _account;
          return internalAccounts[index]!;
        }
      case KeyType.external:
        {
          externalAccounts[index] = _account;
          return externalAccounts[index]!;
        }
      case KeyType.master:
        return masterAccount!;
    }
  }

  Account getAccount({
    required int index,
    required KeyType keyType,
  }) {
    try {
      switch (keyType) {
        case KeyType.internal:
          return internalAccounts[index]!;
        case KeyType.external:
          return externalAccounts[index]!;
        case KeyType.master:
          return masterAccount!;
      }
    } catch (e) {
      return defaultAccount;
    }
  }

  Future<Account> updateAccount({
    required int index,
    required KeyType keyType,
    required Account account,
  }) async {
    ApiDatabase db = Locator.instance<ApiDatabase>();
    switch (keyType) {
      case KeyType.internal:
        if (!internalAccounts.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        internalAccounts[index] = account;
        await db.updateAccount(account);
        return internalAccounts[index]!;
      case KeyType.external:
        if (!externalAccounts.containsKey(index)) {
          await generateKey(index: index, keyType: keyType);
        }
        externalAccounts[index] = account;
        await db.updateAccount(account);
        return externalAccounts[index]!;
      case KeyType.master:
        masterAccount = account;
        await db.updateAccount(account);
        return masterAccount!;
    }
  }

  Map<String, dynamic> accountMapByIndex({
    required KeyType keyType,
  }) {
    switch (keyType) {
      case KeyType.internal:
        Map<String, dynamic> _int = {};
        internalAccounts.forEach((int key, Account value) {
          _int[value.address] = value.jsonMap();
        });
        return _int;
      case KeyType.external:
        Map<String, dynamic> _ext = {};
        externalAccounts.forEach((key, value) {
          _ext[value.address] = value.jsonMap();
        });
        return _ext;
      case KeyType.master:
        return {masterAccount!.address: masterAccount!.jsonMap()};
    }
  }

  Map<String, dynamic> jsonMap() {
    return {
      'id': id,
      'name': name,
      'xprv': xprv,
      'externalXpub': externalXpub,
      'internalXpub': internalXpub,
      'externalAccounts': accountMapByIndex(keyType: KeyType.external),
      'internalAccounts': accountMapByIndex(keyType: KeyType.internal),
      'walletType': "${walletType.name}"
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> data) {
    Map<int, Account> _externalAccounts = {};
    Map<int, Account> _internalAccounts = {};

    _externalAccounts.entries.toList();

    String _id =
        bytesToHex(sha256(data: Xpub.fromXpub(data['externalXpub']).key))
            .substring(0, 8);

    WalletType? _walletType;
    if (data['walletType'] != null) {
      if (data['walletType'] == "hd") {
        _walletType = WalletType.hd;
      } else if (data['walletType'] == "single") {
        _walletType = WalletType.single;
      }
    } else {
      _walletType = WalletType.hd;
    }

    Wallet _wallet = Wallet(
      walletType: _walletType!,
      name: data['name'],
      xprv: data['xprv'],
      externalXpub: data['externalXpub'],
      internalXpub: data['internalXpub'],
      txHashes: [],
      externalAccounts: _externalAccounts,
      internalAccounts: _internalAccounts,
      masterAccount: null,
      masterAccountStats: null,
    );
    _wallet.id = _id;
    return _wallet;
  }

  Future<bool> ensureGapLimit() async {
    try {
      /// if the gap limit is not maintained then generate additional accounts
      int lastExternalIndex = externalAccounts.length;
      int externalGap = 0;
      int internalGap = 0;

      /// check the current external gap between used accounts and the last empty account
      for (int i = 0; i < externalAccounts.length; i++) {
        final Account currentAccount = externalAccounts[i]!;
        if (currentAccount.vttHashes.length > 0) {
          externalGap = 0;
        } else {
          externalGap += 1;
        }
      }

      /// generate new external keys until the EXTERNAL_GAP_LIMIT is reached
      while (externalGap < EXTERNAL_GAP_LIMIT) {
        Account _account = await generateKey(
          index: lastExternalIndex,
          keyType: KeyType.external,
        );
        await Locator.instance<ApiDatabase>().addAccount(_account);
        lastExternalIndex += 1;
        externalGap += 1;
      }

      /// check the current internal gap between used accounts and the last empty account
      for (int i = 0; i < internalAccounts.length; i++) {
        final Account currentAccount = internalAccounts[i]!;
        if (currentAccount.vttHashes.length > 0) {
          internalGap = 0;
        } else {
          internalGap += 1;
        }
      }

      int lastInternalIndex = internalAccounts.length;

      /// generate new internal keys until the INTERNAL_GAP_LIMIT is reached
      while (internalGap < INTERNAL_GAP_LIMIT) {
        Account _account = await generateKey(
          index: lastInternalIndex,
          keyType: KeyType.internal,
        );
        await Locator.instance<ApiDatabase>().addAccount(_account);
        lastInternalIndex += 1;
        internalGap += 1;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void setMasterAccountStats(AccountStats stats) {
    masterAccountStats = stats;
  }

  void setAccount(Account account) {
    switch (account.keyType) {
      case KeyType.internal:
        internalAccounts[account.index] = account;
        break;
      case KeyType.external:
        externalAccounts[account.index] = account;
        break;
      case KeyType.master:
        masterAccount = account;
        break;
    }
  }

  bool containsAccount(String address) {
    bool response = false;
    externalAccounts.forEach((key, value) {
      if (value.address == address) response = true;
    });
    internalAccounts.forEach((key, value) {
      if (value.address == address) response = true;
    });
    if (walletType == WalletType.single) {
      if (masterAccount!.address == address) response = true;
    }
    return response;
  }

  void setTransaction(dynamic transaction) {
    switch (transaction.runtimeType) {
      case ValueTransferInfo:
        {
          List<String> _extAddressList = addressList(KeyType.external);
          List<String> _intAddressList = addressList(KeyType.internal);
          List<String> updatedAccounts = [];
          for (int i = 0; i < _extAddressList.length; i++) {
            Account account = externalAccounts[i]!;
            if (transaction.containsAddress(account.address)) {
              account.addVtt(transaction);
              externalAccounts[i] = account;
              updatedAccounts.add(account.address);
            }
          }
          for (int i = 0; i < _intAddressList.length; i++) {
            Account account = internalAccounts[i]!;
            if (transaction.containsAddress(account.address)) {
              account.addVtt(transaction);
              internalAccounts[i] = account;
              updatedAccounts.add(account.address);
            }
          }
        }
        break;
      case MintEntry:
        {
          if (walletType == WalletType.single) {
            masterAccount!.mintHashes.add(transaction.blockHash);
            masterAccount!.addMint(transaction);
          }
        }
        break;
      default:
        break;
    }
  }

  void printDebug() {
    print('Wallet');
    print(' ID: $id');
    print(' name: $name');
    print(' vtt count: ${txHashes.length}');

    print(' External Accounts:');

    externalAccounts.forEach((key, value) {
      print('  ${value.path}\t${value.address} ');
    });
    print(' Internal Accounts:');
    internalAccounts.forEach((key, value) {
      print('  ${value.path}\t${value.address} ');
    });
  }
}
