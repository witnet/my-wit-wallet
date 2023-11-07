import 'package:flutter_test/flutter_test.dart';

void main() {
  group('syncWalletRoutine', () {
    test('HD wallet should iterate through all addresses', () => {});
    test('NODE wallet should iterate through masterAccount', () => {});
    //HD WALLET
    test('Should get utxos from explorer', () => {});
    test('[ACCOUNT] Should update account utxo list', () => {});
    test(
        '[ACCOUNT] Should update account vtt and balance with utxos from explorer',
        () => {});
    // storage set vtt or update vtt explorer_bloc.dart
    // setVtt wallet_storage.dart
    // wallets list set transaction wallet.dart
    // account.addTransaction wallet.dart
    // for each input output vtts add account.dart
    // account update vtt hashed
    test('[CURRENT WALLET] Should update current wallet with updated account',
        () => {});
    test(
        '[STORAGE] Should update current wallet within wallet list in storage with new wallet updated, ¿Does update account update current wallet?',
        () => {});
    //NODE WALLET
    test('Should update db stats from explorer IF NODE ADDRESS', () => {});
    // UPDATE UNCONFIRMED VTTS
    // loop over unconfirmed vtts
    test('Should get vtt info from explorer', () => {});
    test('Should update vtt status in DB if it changes', () => {});
    test('If vtt returns null delete vtt in account from inputs', () => {});
    test('If vtt returns null delete vtt in account from outputs', () => {});
    test('Delete vtt in DB', () => {});
    // FINISH
    test('Load wallet DB', () => {});
    test('Update current wallet DB', () => {});
    test('Returl updated storage', () => {});
  });
}
