import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet/witnet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_isolate.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';

abstract class ImportXprvEvent {}

class NextCardEvent extends ImportXprvEvent {}

class PreviousCardEvent extends ImportXprvEvent {}

class VerifyXprvEvent extends ImportXprvEvent {
  final String xprv;
  VerifyXprvEvent(this.xprv);
}

class SetStateEvent extends ImportXprvEvent {
  final ImportXprvState state;
  SetStateEvent(this.state);
}

abstract class ImportXprvState {}

class ImportXprvDisclaimerState extends ImportXprvState {}

class EnterXprvState extends ImportXprvState {}

class ValidXprvState extends ImportXprvState {
  final String xprvString;
  final String nodeAddress;
  final String walletAddress;
  ValidXprvState(this.xprvString, this.nodeAddress, this.walletAddress);
}

class WalletDetailState extends ImportXprvState {}

class EncryptWalletState extends ImportXprvState {}

class BuildWalletState extends ImportXprvState {}

class LoadingState extends ImportXprvState {}

class LoadingErrorState extends ImportXprvState {
  final List<dynamic> errors;
  LoadingErrorState(this.errors);
}

class BlocImportXprv extends Bloc<ImportXprvEvent, ImportXprvState> {
  BlocImportXprv(initialState) : super(initialState);
  get initialState => ImportXprvDisclaimerState();

  @override
  Stream<ImportXprvState> mapEventToState(ImportXprvEvent event) async* {
    try {
      if (event is NextCardEvent) {
        switch (state.runtimeType) {
          case ImportXprvDisclaimerState:
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
          case ImportXprvDisclaimerState:
            yield ImportXprvDisclaimerState();
            break;
          case EnterXprvState:
            yield ImportXprvDisclaimerState();
            break;
          case ValidXprvState:
            yield ImportXprvDisclaimerState();
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
        String xprvStr = event.xprv;

        Xprv _xprv;
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

          yield ValidXprvState(event.xprv, wallet.masterXprv.address.address,
              wallet.externalKeys[0]!.address.address);
        } catch (e) {
          errors.add(e.runtimeType.toString());
          yield LoadingErrorState(errors);
        }
      } else if (event is SetStateEvent) {
        switch (event.state.runtimeType) {
          case EnterXprvState:
            yield EnterXprvState();
        }
      }
    } catch (e) {}
  }
}
