part of 'create_wallet_bloc.dart';

enum CreateWalletStatus {
  Disclaimer,
  Imported,
  GenerateMnemonic,
  EnterMnemonic,
  EnterXprv,
  ValidXprv,
  EnterEncryptedXprv,
  ConfirmMnemonic,
  WalletDetail,
  EncryptWallet,
  BuildWallet,
  CreateWallet,
  Complete,
  Loading,
  LoadingException,
  Reset,
}

class CreateWalletState extends Equatable {
  const CreateWalletState({
    required this.walletType,
    required this.message,
    required this.xprvString,
    required this.nodeAddress,
    required this.walletAddress,
    required this.status,
  });

  final CreateWalletStatus status;
  final WalletType walletType;
  final String? message;
  final String? xprvString;
  final String? nodeAddress;
  final String? walletAddress;

  CreateWalletState copyWith({
    WalletType? walletType,
    String? message,
    String? xprvString,
    String? nodeAddress,
    String? walletAddress,
    CreateWalletStatus? status,
  }) {
    return CreateWalletState(
      walletType: walletType ?? this.walletType,
      message: message ?? this.message,
      xprvString: xprvString ?? this.xprvString,
      nodeAddress: nodeAddress ?? this.nodeAddress,
      walletAddress: walletAddress ?? this.walletAddress,
      status: status ?? this.status,
    );
  }


  @override
  List<Object?> get props =>
      [walletType, message, xprvString, nodeAddress, walletAddress, status];
}
