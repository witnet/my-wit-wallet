import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/bloc/api_create_wallet.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';

import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/wallet.dart';
import 'package:equatable/equatable.dart';

part 'create_wallet_state.dart';
part 'create_wallet_event.dart';

enum WalletType {
  unset,
  newWallet,
  mnemonic,
  xprv,
  encryptedXprv,
}

enum CreateWalletCards {
  disclaimer,
  enterMnemonic,
  enterXprv,
  enterEncryptedXprv,
  walletDetails,
  generateMnemonic,
}

class CreateWalletBloc extends Bloc<CreateWalletEvent, CreateWalletState> {
  CreateWalletBloc(initialState) : super(initialState) {
    on<NextCardEvent>(_nextCardEvent);
    on<PreviousCardEvent>(_previousCardEvent);
    on<GenerateMnemonicEvent>(_generateMnemonicEvent);
    on<VerifyXprvEvent>(_verifyXprvEvent);
    on<VerifyEncryptedXprvEvent>(_verifyEncryptedXprvEvent);
    on<SetWalletTypeEvent>(_setWalletTypeEvent);
    on<FinishEvent>(_finishEvent);
    on<ResetEvent>(_resetEvent);
  }

  CreateWalletState get initialState => CreateWalletState(
      walletType: WalletType.unset,
      message: null,
      xprvString: null,
      nodeAddress: null,
      walletAddress: null,
      status: CreateWalletStatus.Imported);

  void _nextCardEvent(
      CreateWalletEvent event, Emitter<CreateWalletState> emit) {
    switch (state.status) {
      case CreateWalletStatus.Disclaimer:
        switch (event.walletType) {
          case WalletType.unset:
            break;
          case WalletType.newWallet:
            emit(state.copyWith(status: CreateWalletStatus.GenerateMnemonic));
            break;
          case WalletType.mnemonic:
            emit(state.copyWith(status: CreateWalletStatus.EnterMnemonic));
            break;
          case WalletType.xprv:
            emit(state.copyWith(status: CreateWalletStatus.EnterXprv));
            break;
          case WalletType.encryptedXprv:
            emit(state.copyWith(status: CreateWalletStatus.EnterEncryptedXprv));
            break;
        }
        break;

      case CreateWalletStatus.GenerateMnemonic:
        emit(state.copyWith(status: CreateWalletStatus.ConfirmMnemonic));
        break;

      case CreateWalletStatus.EnterMnemonic:
        emit(state.copyWith(status: CreateWalletStatus.WalletDetail));
        break;

      case CreateWalletStatus.EnterXprv:
        emit(state.copyWith(status: CreateWalletStatus.WalletDetail));
        break;

      case CreateWalletStatus.ValidXprv:
        emit(state.copyWith(status: CreateWalletStatus.WalletDetail));
        break;

      case CreateWalletStatus.EnterEncryptedXprv:
        emit(state.copyWith(status: CreateWalletStatus.WalletDetail));
        break;

      case CreateWalletStatus.ConfirmMnemonic:
        emit(state.copyWith(status: CreateWalletStatus.WalletDetail));
        break;

      case CreateWalletStatus.WalletDetail:
        emit(state.copyWith(status: CreateWalletStatus.EncryptWallet));
        break;

      case CreateWalletStatus.EncryptWallet:
        emit(state.copyWith(status: CreateWalletStatus.BuildWallet));
        break;

      case CreateWalletStatus.BuildWallet:
        emit(state.copyWith(status: CreateWalletStatus.Complete));
        break;

      case CreateWalletStatus.CreateWallet:
        break;

      case CreateWalletStatus.Imported:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;

      case CreateWalletStatus.Complete:
        break;

      case CreateWalletStatus.Loading:
        break;

      case CreateWalletStatus.LoadingException:
        break;

      case CreateWalletStatus.Reset:
        break;
    }
  }

  void _previousCardEvent(
      CreateWalletEvent event, Emitter<CreateWalletState> emit) {
    switch (state.status) {
      case CreateWalletStatus.Disclaimer:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.GenerateMnemonic:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.EnterMnemonic:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.EnterXprv:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.ValidXprv:
        emit(state.copyWith(status: CreateWalletStatus.EnterXprv));
        break;
      case CreateWalletStatus.EnterEncryptedXprv:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.ConfirmMnemonic:
        if (event.walletType == WalletType.newWallet) {
          emit(state.copyWith(status: CreateWalletStatus.GenerateMnemonic));
        } else {
          emit(state.copyWith(status: CreateWalletStatus.EnterMnemonic));
        }
        break;
      case CreateWalletStatus.WalletDetail:
        emit(state.copyWith(status: CreateWalletStatus.ConfirmMnemonic));
        break;
      case CreateWalletStatus.EncryptWallet:
        emit(state.copyWith(status: CreateWalletStatus.WalletDetail));
        break;
      case CreateWalletStatus.BuildWallet:
        emit(state.copyWith(status: CreateWalletStatus.EncryptWallet));
        break;
      case CreateWalletStatus.CreateWallet:
        emit(state.copyWith(status: CreateWalletStatus.BuildWallet));
        break;
      case CreateWalletStatus.Complete:
        emit(state.copyWith(status: CreateWalletStatus.CreateWallet));
        break;
      case CreateWalletStatus.Imported:
        emit(state.copyWith(status: CreateWalletStatus.Imported));
        break;
      case CreateWalletStatus.Loading:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.LoadingException:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.Reset:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
    }
  }

  void _generateMnemonicEvent(
      GenerateMnemonicEvent event, Emitter<CreateWalletState> emit) async {
    await Locator.instance
        .get<ApiCreateWallet>()
        .createMnemonic(wordCount: event.length, language: event.language);
    // emit(GenerateMnemonicState(event.walletType, ));
  }

  void _verifyXprvEvent(
      VerifyXprvEvent event, Emitter<CreateWalletState> emit) async {
    String xprvStr = event.xprv;

    var errors = ['Invalid XPRV:'];
    if (xprvStr.isEmpty) errors.add('Field is blank');
    if (!xprvStr.startsWith('xprv1')) errors.add('needs to start with "xprv1"');
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

      emit(state.copyWith(
          xprvString: event.xprv,
          nodeAddress: wallet.masterXprv.address.address,
          walletAddress: wallet.externalKeys[0]!.address,
          status: CreateWalletStatus.ValidXprv));
    } catch (e) {}
  }

  void _verifyEncryptedXprvEvent(
      VerifyEncryptedXprvEvent event, Emitter<CreateWalletState> emit) async {
    emit(state.copyWith(status: CreateWalletStatus.Loading));
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
      Wallet wallet = await resp.first.then((value) {
        return value;
      });

      print(wallet.masterXprv.toSlip32());
      print(wallet.masterXprv.address.address);
      print(wallet.externalKeys);

      emit(state.copyWith(
        xprvString: wallet.masterXprv.toSlip32(),
        nodeAddress: wallet.masterXprv.address.address,
        status: CreateWalletStatus.ValidXprv,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: CreateWalletStatus.LoadingException, message: e.toString()));
    }
  }

  void _setWalletTypeEvent(
      SetWalletTypeEvent event, Emitter<CreateWalletState> emit) {
    emit(state.copyWith(
        walletType: event.walletType, status: _getStatus(event)));
  }

  void _finishEvent(FinishEvent event, Emitter<CreateWalletState> emit) {
    emit(state.copyWith(status: CreateWalletStatus.Complete));
  }

  void _resetEvent(ResetEvent event, Emitter<CreateWalletState> emit) {
    emit(state.copyWith(
        walletType: event.walletType, status: _getStatus(event)));
  }

  _getStatus(CreateWalletEvent event) {
    if (event.walletType == WalletType.newWallet) {
      return CreateWalletStatus.Disclaimer;
    }
    if (event.walletType == WalletType.unset) {
      return CreateWalletStatus.Imported;
    }
  }
}
