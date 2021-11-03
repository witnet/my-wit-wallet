import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

abstract class ImportEncryptedXprvEvent {}

class NextCardEvent extends ImportEncryptedXprvEvent {}

class PreviousCardEvent extends ImportEncryptedXprvEvent {}

class VerifyXprvEvent extends ImportEncryptedXprvEvent {
  final String xprv;
  final String password;
  VerifyXprvEvent(this.xprv, this.password);
}

class SetStateEvent extends ImportEncryptedXprvEvent {
  final ImportEncryptedXprvState state;
  SetStateEvent(this.state);
}

abstract class ImportEncryptedXprvState {}

class ImportEncryptedXprvDisclaimerState extends ImportEncryptedXprvState {}

class EnterXprvState extends ImportEncryptedXprvState {}

class ValidXprvState extends ImportEncryptedXprvState {
  final String xprvString;
  final String nodeAddress;
  final String walletAddress;
  ValidXprvState(this.xprvString, this.nodeAddress, this.walletAddress);
}

class WalletDetailState extends ImportEncryptedXprvState {}

class EncryptWalletState extends ImportEncryptedXprvState {}

class BuildWalletState extends ImportEncryptedXprvState {}

class LoadingState extends ImportEncryptedXprvState {}

class LoadingErrorState extends ImportEncryptedXprvState {
  final errors;
  LoadingErrorState(this.errors);
}

class BlocImportEcnryptedXprv
    extends Bloc<ImportEncryptedXprvEvent, ImportEncryptedXprvState> {
  BlocImportEcnryptedXprv(initialState) : super(initialState);
  get initialState => ImportEncryptedXprvDisclaimerState();

  @override
  Stream<ImportEncryptedXprvState> mapEventToState(
      ImportEncryptedXprvEvent event) async* {
    print(event.runtimeType);
    try {
      if (event is NextCardEvent) {
        switch (state.runtimeType) {
          case ImportEncryptedXprvDisclaimerState:
            yield EnterXprvState();
            break;
          case ValidXprvState:
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
          case ImportEncryptedXprvDisclaimerState:
            yield ImportEncryptedXprvDisclaimerState();
            break;
          case EnterXprvState:
            yield ImportEncryptedXprvDisclaimerState();
            break;
          case ValidXprvState:
            yield ImportEncryptedXprvDisclaimerState();
            break;
          case WalletDetailState:
            yield EnterXprvState();
            break;
          case EncryptWalletState:
            yield WalletDetailState();
            break;
          case BuildWalletState:
            yield EncryptWalletState();
            break;
        }
      } else if (event is VerifyXprvEvent) {
        yield LoadingState();

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
            print(value);
            print(val);
            if (val.containsKey('error')) {
              errors.add(val['error']);
              print('the Error ${val['error']!.runtimeType.toString()}');
            }
            return value;
          });
          Wallet wallet = tmp['wallet'] as Wallet;
          yield ValidXprvState(
              wallet.masterXprv.toSlip32(),
              wallet.masterXprv.address.address,
              wallet.externalKeys[0]!.address.address);
          print(errors);
          if (errors.length > 0) {
            yield LoadingErrorState(errors);
          }
          } catch (e) {
          yield LoadingErrorState([e.toString()]);
        }
      } else if (event is SetStateEvent) {
        switch (event.state.runtimeType) {
          case EnterXprvState:
            yield EnterXprvState();
            break;
        }
      }
    } catch (e) {}
  }
}
