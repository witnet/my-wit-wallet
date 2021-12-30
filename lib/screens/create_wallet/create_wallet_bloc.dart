import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/bloc/auth/create_wallet/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

/// Events
abstract class CreateWalletEvent {
  final WalletType type;
  CreateWalletEvent(this.type);
}

enum WalletType {
  newWallet,
  mnemonic,
  xprv,
  encryptedXprv,
}

class SetWalletTypeEvent extends CreateWalletEvent {
  SetWalletTypeEvent(WalletType type) : super(type);
}

class SetStateEvent extends CreateWalletEvent {
  final WalletType type;
  final CreateWalletState state;
  SetStateEvent(this.type, this.state) : super(type);
}

class NextCardEvent extends CreateWalletEvent {
  Map<String, dynamic>? data;
  NextCardEvent(WalletType type, {this.data}) : super(type);
}

class VerifyXprvEvent extends CreateWalletEvent {
  final String xprv;
  VerifyXprvEvent(WalletType type, this.xprv) : super(type);
}

class VerifyEncryptedXprvEvent extends CreateWalletEvent {
  final String xprv;
  final String password;
  VerifyEncryptedXprvEvent(WalletType type, this.xprv, this.password)
      : super(type);
}

class PreviousCardEvent extends CreateWalletEvent {
  PreviousCardEvent(WalletType type) : super(type);
}

class GenerateMnemonicEvent extends CreateWalletEvent {
  final int length;
  final String language;
  GenerateMnemonicEvent(WalletType type,
      {required this.length, required this.language})
      : super(type);
}

class ResetEvent extends CreateWalletEvent {
  ResetEvent(WalletType type) : super(type);
}

class FinishEvent extends CreateWalletEvent {
  FinishEvent(WalletType type) : super(type);
}

/// States
abstract class CreateWalletState {
  CreateWalletState(this.type);
  final WalletType type;
}

class DisclaimerState extends CreateWalletState {
  DisclaimerState(WalletType type) : super(type);
}

class GenerateMnemonicState extends CreateWalletState {
  GenerateMnemonicState(WalletType type) : super(type);
}

class EnterMnemonicState extends CreateWalletState {
  EnterMnemonicState(WalletType type) : super(type);
}

class EnterXprvState extends CreateWalletState {
  EnterXprvState(WalletType type) : super(type);
}

class ValidXprvState extends CreateWalletState {
  final String xprvString;
  final String nodeAddress;
  final String walletAddress;
  ValidXprvState(
      WalletType type, this.xprvString, this.nodeAddress, this.walletAddress)
      : super(type);
}

class EnterEncryptedXprvState extends CreateWalletState {
  EnterEncryptedXprvState(WalletType type) : super(type);
}

class ConfirmMnemonicState extends CreateWalletState {
  ConfirmMnemonicState(WalletType type) : super(type);
}

class WalletDetailState extends CreateWalletState {
  WalletDetailState(WalletType type) : super(type);
}

class EncryptWalletState extends CreateWalletState {
  EncryptWalletState(WalletType type) : super(type);
}

class BuildWalletState extends CreateWalletState {
  BuildWalletState(WalletType type) : super(type);
}

class CreateWalletErrorState extends CreateWalletState {
  CreateWalletErrorState(WalletType type) : super(type);
}

class CompleteState extends CreateWalletState {
  CompleteState(WalletType type) : super(type);
}

class LoadingState extends CreateWalletState {
  LoadingState(WalletType type) : super(type);
}

class LoadingErrorState extends CreateWalletState {
  final errors;
  LoadingErrorState(WalletType type, this.errors) : super(type);
}

class ResetState extends CreateWalletState {
  ResetState(WalletType type) : super(type);
}

/// BLOC
class BlocCreateWallet extends Bloc<CreateWalletEvent, CreateWalletState> {
  BlocCreateWallet(initialState) : super(initialState);
  get initialState => DisclaimerState(WalletType.newWallet);
  WalletType? type;

  @override
  Stream<CreateWalletState> mapEventToState(CreateWalletEvent event) async* {
    try {
      WalletType type = Locator.instance<ApiCreateWallet>().walletType;
      if (event is NextCardEvent) {
        switch (state.runtimeType) {
          case DisclaimerState:
            switch (type) {
              case WalletType.newWallet:
                yield GenerateMnemonicState(type);
                break;
              case WalletType.mnemonic:
                yield EnterMnemonicState(type);
                break;
              case WalletType.xprv:
                yield EnterXprvState(type);
                break;
              case WalletType.encryptedXprv:
                yield EnterEncryptedXprvState(type);
                break;
            }

            break;
          case EnterMnemonicState:
            yield WalletDetailState(type);
            break;
          case EnterXprvState:
            break;
          case GenerateMnemonicState:
            yield ConfirmMnemonicState(type);
            break;
          case ConfirmMnemonicState:
            yield WalletDetailState(type);
            break;
          case WalletDetailState:
            yield EncryptWalletState(type);
            break;
          case EncryptWalletState:
            yield BuildWalletState(type);
            break;
          case BuildWalletState:
            yield CompleteState(type);
            break;
        }
      } else if (event is PreviousCardEvent) {
        switch (state.runtimeType) {
          case DisclaimerState:
            yield DisclaimerState(type);
            break;
          case EnterMnemonicState:
            yield DisclaimerState(type);
            break;
          case EnterXprvState:
            yield DisclaimerState(type);
            break;
          case EnterEncryptedXprvState:
            yield DisclaimerState(type);
            break;
          case GenerateMnemonicState:
            yield DisclaimerState(type);
            break;
          case ConfirmMnemonicState:
            yield GenerateMnemonicState(type);
            break;
          case WalletDetailState:
            yield ConfirmMnemonicState(type);
            break;
          case EncryptWalletState:
            yield WalletDetailState(type);
            break;
          case BuildWalletState:
            yield EncryptWalletState(type);
            break;
          case CompleteState:
            yield BuildWalletState(type);
            break;
        }
      } else if (event is GenerateMnemonicEvent) {
        await Locator.instance
            .get<ApiCreateWallet>()
            .createMnemonic(wordCount: event.length, language: event.language);
      } else if (event is VerifyXprvEvent) {
        yield LoadingState(type);
        String xprvStr = event.xprv;

        var errors = ['Invalid XPRV:'];
        if (xprvStr.isEmpty) errors.add('Field is blank');
        if (!xprvStr.startsWith('xprv1'))
          errors.add('needs to start with "xprv1"');
        try {
          CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
          await cryptoIsolate.init();
          ReceivePort resp = ReceivePort();
          cryptoIsolate.send(
              method: 'initializeWallet',
              params: {
                'walletName': '',
                'walletDescription': '',
                'seed': event.xprv,
                'seedSource': 'xprv'
              },
              port: resp.sendPort);

          Wallet wallet = await resp.first.then((value) {
            return value['wallet'] as Wallet;
          });

          yield ValidXprvState(
              event.type,
              event.xprv,
              wallet.masterXprv.address.address,
              wallet.externalKeys[0]!.address);
        } catch (e) {
          errors.add(e.runtimeType.toString());
          yield LoadingErrorState(event.type, errors);
        }
      } else if (event is VerifyEncryptedXprvEvent) {
        yield LoadingState(event.type);

        try {
          CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
          await cryptoIsolate.init();
          ReceivePort resp = ReceivePort();
          cryptoIsolate.send(
              method: 'initializeWallet',
              params: {
                'walletName': '_loading',
                'walletDescription': '_loading',
                'seed': event.xprv,
                'seedSource': 'encryptedXprv',
                'password': event.password
              },
              port: resp.sendPort);
          var errors = [];
          var tmp = await resp.first.then((value) {
            var val = value as Map<String, Object?>;

            if (val.containsKey('error')) {
              errors.add(val['error']);
            }
            return value;
          });
          Wallet wallet = tmp['wallet'] as Wallet;
          yield ValidXprvState(
              event.type,
              wallet.masterXprv.toSlip32(),
              wallet.masterXprv.address.address,
              wallet.externalKeys[0]!.address);
          if (errors.length > 0) {
            yield LoadingErrorState(event.type, errors);
          }
        } catch (e) {
          yield LoadingErrorState(event.type, [e.toString()]);
        }
      } else if (event is SetWalletTypeEvent) {
        type = event.type;
      } else if (event is FinishEvent) {
        yield CompleteState(event.type);
      } else if (event is ResetEvent) {
        yield DisclaimerState(event.type);
      }
    } catch (e) {}
  }
}
