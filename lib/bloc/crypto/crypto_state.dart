part of 'crypto_bloc.dart';

/// States
class CryptoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CryptoReadyState extends CryptoState {
  @override
  List<Object?> get props => [];
}

class CryptoInitializingWalletState extends CryptoState {
  final String message;
  final int balanceNanoWit;
  final int transactionCount;
  final int addressCount;

  CryptoInitializingWalletState(
      {required this.message,
      required this.balanceNanoWit,
      required this.transactionCount,
      required this.addressCount});

  @override
  List<Object?> get props =>
      [message, balanceNanoWit, transactionCount, addressCount];
}

class CryptoLoadedWalletState extends CryptoState {
  final Wallet wallet;
  final String password;
  final DbWallet dbWallet;

  CryptoLoadedWalletState(
      {required this.wallet, required this.password, required this.dbWallet});

  @override
  List<Object?> get props => [wallet, password];
}

class CryptoLoadingState extends CryptoState {
  @override
  List<Object?> get props => [];
}

class CryptoLoadedState extends CryptoState {
  @override
  List<Object?> get props => [];
}

class CryptoExceptionState extends CryptoState {
  CryptoExceptionState({required this.code, required this.message});

  final int code;
  final String message;

  @override
  List<Object> get props => [code, message];
}
