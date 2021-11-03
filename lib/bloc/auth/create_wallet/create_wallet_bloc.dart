import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/shared/locator.dart';

/// Events
abstract class CreateWalletEvent {}

class NextCardEvent extends CreateWalletEvent {
  Map<String, dynamic>? data;
  NextCardEvent({this.data});
}

class PreviousCardEvent extends CreateWalletEvent {}

class GenerateMnemonicEvent extends CreateWalletEvent {
  final int length;
  final String language;
  GenerateMnemonicEvent({required this.length, required this.language});
}

/// States
abstract class CreateWalletState {}

class DisclaimerState extends CreateWalletState {}

class GenerateMnemonicState extends CreateWalletState {}

class ConfirmMnemonicState extends CreateWalletState {}

class WalletDetailState extends CreateWalletState {}

class EncryptWalletState extends CreateWalletState {}

class BuildWalletState extends CreateWalletState {}

class CreateWalletErrorState extends CreateWalletState {}

class CompleteState extends CreateWalletState {}

class ResetState extends CreateWalletState {}

/// BLOC
class BlocCreateWallet extends Bloc<CreateWalletEvent, CreateWalletState> {
  BlocCreateWallet(initialState) : super(initialState);
  get initialState => DisclaimerState();

  @override
  Stream<CreateWalletState> mapEventToState(CreateWalletEvent event) async* {
    try {
      if (event is NextCardEvent) {
        switch (state.runtimeType) {
          case DisclaimerState:
            yield GenerateMnemonicState();
            break;
          case GenerateMnemonicState:
            yield ConfirmMnemonicState();
            break;
          case ConfirmMnemonicState:
            yield WalletDetailState();
            break;
          case WalletDetailState:
            yield EncryptWalletState();
            break;
          case EncryptWalletState:
            yield BuildWalletState();
            break;
          case BuildWalletState:
            yield CompleteState();
            break;
        }
      } else if (event is PreviousCardEvent) {
        switch (state.runtimeType) {
          case DisclaimerState:
            yield DisclaimerState();
            break;
          case GenerateMnemonicState:
            yield DisclaimerState();
            break;
          case ConfirmMnemonicState:
            yield GenerateMnemonicState();
            break;
          case WalletDetailState:
            yield ConfirmMnemonicState();
            break;
          case EncryptWalletState:
            yield WalletDetailState();
            break;
          case BuildWalletState:
            yield EncryptWalletState();
            break;
          case CompleteState:
            yield BuildWalletState();
            break;
        }
      } else if (event is GenerateMnemonicEvent) {
        await Locator.instance
            .get<ApiCreateWallet>()
            .createMnemonic(wordCount: event.length, language: event.language);
      }
    } catch (e) {}
  }
}
