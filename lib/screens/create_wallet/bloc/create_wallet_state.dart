part of 'create_wallet_bloc.dart';

enum CreateWalletStatus {
  Disclaimer,
  // Imported is the status where you should choose the imported option (seed phrase or xprv)
  Imported,
  CreateImport,
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
    required this.createWalletType,
    required this.message,
    required this.xprvString,
    required this.nodeAddress,
    required this.walletAddress,
    required this.status,
  });

  final CreateWalletStatus status;
  final CreateWalletType createWalletType;
  final String? message;
  final String? xprvString;
  final String? nodeAddress;
  final String? walletAddress;

  CreateWalletState copyWith({
    CreateWalletType? walletType,
    String? message,
    String? xprvString,
    String? nodeAddress,
    String? walletAddress,
    CreateWalletStatus? status,
  }) {
    return CreateWalletState(
      createWalletType: walletType ?? this.createWalletType,
      xprvString: xprvString ?? this.xprvString,
      message: message ?? this.message,
      nodeAddress: nodeAddress ?? this.nodeAddress,
      walletAddress: walletAddress ?? this.walletAddress,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        createWalletType,
        message,
        xprvString,
        nodeAddress,
        walletAddress,
        status,
      ];
}
