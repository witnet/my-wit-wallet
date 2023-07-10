part of 'create_wallet_bloc.dart';

abstract class CreateWalletEvent extends Equatable {
  const CreateWalletEvent(this.walletType);
  final CreateWalletType walletType;
  @override
  List<Object> get props => [this.walletType];
}

class SetWalletStateEvent extends CreateWalletEvent {
  const SetWalletStateEvent(CreateWalletType walletType, this.walletState)
      : super(walletType);
  final CreateWalletState walletState;

  @override
  List<Object> get props => [this.walletType, this.walletState];
}

class NextCardEvent extends CreateWalletEvent {
  const NextCardEvent(CreateWalletType walletType, {required this.data})
      : super(walletType);
  final Map<String, dynamic> data;
  @override
  List<Object> get props => [this.walletType, this.data];
}

class VerifyXprvEvent extends CreateWalletEvent {
  const VerifyXprvEvent(CreateWalletType walletType, {required this.xprv})
      : super(walletType);
  final String xprv;
  @override
  List<Object> get props => [this.walletType, this.xprv];
}

class VerifyEncryptedXprvEvent extends CreateWalletEvent {
  const VerifyEncryptedXprvEvent(CreateWalletType walletType,
      {required this.xprv, required this.password})
      : super(walletType);
  final String xprv;
  final String password;

  @override
  List<Object> get props => [this.walletType, this.xprv, this.password];
}

class PreviousCardEvent extends CreateWalletEvent {
  const PreviousCardEvent(CreateWalletType walletType) : super(walletType);
}

class GenerateMnemonicEvent extends CreateWalletEvent {
  const GenerateMnemonicEvent(CreateWalletType walletType,
      {required this.length, required this.language})
      : super(walletType);
  final int length;
  final String language;

  @override
  List<Object> get props => [this.walletType, this.length, this.language];
}

class ResetEvent extends CreateWalletEvent {
  const ResetEvent(CreateWalletType walletType) : super(walletType);
}

class FinishEvent extends CreateWalletEvent {
  const FinishEvent(CreateWalletType walletType) : super(walletType);
}
