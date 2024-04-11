part of 'crypto_bloc.dart';

/// Events
class CryptoEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CryptoInitializeWalletEvent extends CryptoEvent {
  final String id;
  final String walletName;
  final String keyData;
  final String seedSource;
  final String password;
  final WalletType walletType;

  CryptoInitializeWalletEvent(
      {required this.id,
      required this.walletName,
      required this.keyData,
      required this.seedSource,
      required this.password,
      required this.walletType,
      int addressCount = 10});

  @override
  List<Object> get props => [walletName, keyData, password, seedSource];
}

class CryptoReadyEvent extends CryptoEvent {}

class CryptoComputeEvent extends CryptoEvent {}

class CryptoDoneEvent extends CryptoEvent {}

class CryptoInitWalletDoneEvent extends CryptoEvent {
  final Wallet wallet;
  final String password;
  final Map<int, Account> externalAccounts;
  final Map<int, Account> internalAccounts;

  CryptoInitWalletDoneEvent({
    required this.wallet,
    required this.password,
    required this.internalAccounts,
    required this.externalAccounts,
  });

  @override
  List<Object> get props =>
      [wallet, password, externalAccounts, internalAccounts];
}

class CryptoExceptionEvent extends CryptoEvent {
  CryptoExceptionEvent({required this.message});
  final String message;
  @override
  List<Object> get props => [message];
}
