import 'package:bloc/bloc.dart';

abstract class ImportMnemonicEvent {}

class NextCardEvent extends ImportMnemonicEvent {}

class PreviousCardEvent extends ImportMnemonicEvent {}

abstract class ImportMnemonicState {}

class ImportMnemonicDisclaimerState extends ImportMnemonicState {}

class EnterMnemonicState extends ImportMnemonicState {}

class WalletDetailState extends ImportMnemonicState {}

class EncryptWalletState extends ImportMnemonicState {}

class BuildWalletState extends ImportMnemonicState {}

class BlocImportMnemonic
    extends Bloc<ImportMnemonicEvent, ImportMnemonicState> {
  BlocImportMnemonic(initialState) : super(initialState);
  get initialState => ImportMnemonicDisclaimerState();

  @override
  Stream<ImportMnemonicState> mapEventToState(
      ImportMnemonicEvent event) async* {
    try {
      if (event is NextCardEvent) {
        switch (state.runtimeType) {
          case ImportMnemonicDisclaimerState:
            yield EnterMnemonicState();
            break;
          case EnterMnemonicState:
            yield WalletDetailState();
            break;
          case WalletDetailState:
            yield EncryptWalletState();
            break;
          case EncryptWalletState:
            yield BuildWalletState();
            break;
        }
      } else if (event is PreviousCardEvent) {
        switch (state.runtimeType) {
          case ImportMnemonicDisclaimerState:
            yield ImportMnemonicDisclaimerState();
            break;
          case EnterMnemonicState:
            yield ImportMnemonicDisclaimerState();
            break;
          case WalletDetailState:
            yield EnterMnemonicState();
            break;
          case EncryptWalletState:
            yield WalletDetailState();
            break;
          case BuildWalletState:
            yield EncryptWalletState();
            break;
        }
      }
    } catch (e) {}
  }
}
