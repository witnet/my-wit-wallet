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
  final BalanceInfo balanceInfo;
  final int transactionCount;
  final int addressCount;

  CryptoInitializingWalletState({
    required this.message,
    required this.balanceInfo,
    required this.transactionCount,
    required this.addressCount,
  });

  @override
  List<Object?> get props =>
      [message, balanceInfo, transactionCount, addressCount];
}

class CryptoLoadedWalletState extends CryptoState {
  final Wallet wallet;
  final String password;

  CryptoLoadedWalletState({
    required this.wallet,
    required this.password,
  });

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
  CryptoExceptionState({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object> get props => [errorMessage];
}
