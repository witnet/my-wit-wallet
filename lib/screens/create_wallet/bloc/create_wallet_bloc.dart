import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

part 'create_wallet_event.dart';

part 'create_wallet_state.dart';

enum CreateWalletType {
  unset,
  reset,
  imported,
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
    on<FinishEvent>(_finishEvent);
    on<ResetEvent>(_resetEvent);
  }

  CreateWalletState get initialState => CreateWalletState(
      createWalletType: CreateWalletType.imported,
      message: null,
      xprvString: null,
      nodeAddress: null,
      walletAddress: null,
      status: CreateWalletStatus.Imported);
  ApiDatabase database = Locator.instance.get<ApiDatabase>();

  void _nextCardEvent(
      CreateWalletEvent event, Emitter<CreateWalletState> emit) async {
    final masterKey = await database.getKeychain();
    switch (state.status) {
      case CreateWalletStatus.Disclaimer:
        switch (event.walletType) {
          case CreateWalletType.imported:
            break;
          case CreateWalletType.unset:
            break;
          case CreateWalletType.reset:
            break;
          case CreateWalletType.newWallet:
            emit(state.copyWith(status: CreateWalletStatus.GenerateMnemonic));
            break;
          case CreateWalletType.mnemonic:
            emit(state.copyWith(status: CreateWalletStatus.EnterMnemonic));
            break;
          case CreateWalletType.xprv:
            emit(state.copyWith(status: CreateWalletStatus.EnterXprv));
            break;
          case CreateWalletType.encryptedXprv:
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
        if (masterKey != '') {
          emit(state.copyWith(status: CreateWalletStatus.BuildWallet));
        } else {
          emit(state.copyWith(status: CreateWalletStatus.EncryptWallet));
        }
        break;

      case CreateWalletStatus.EncryptWallet:
        emit(state.copyWith(status: CreateWalletStatus.BuildWallet));
        break;

      case CreateWalletStatus.BuildWallet:
        emit(state.copyWith(status: CreateWalletStatus.Complete));
        break;

      case CreateWalletStatus.CreateWallet:
        break;

      // Decide whether to import wallet from seed phrase or import from xprv file
      case CreateWalletStatus.Imported:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;

      case CreateWalletStatus.CreateImport:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;

      case CreateWalletStatus.Reset:
        break;

      case CreateWalletStatus.Complete:
        break;

      case CreateWalletStatus.Loading:
        break;

      case CreateWalletStatus.LoadingException:
        break;
    }
  }

  void _previousCardEvent(
      CreateWalletEvent event, Emitter<CreateWalletState> emit) {
    switch (state.status) {
      case CreateWalletStatus.Disclaimer:
        if (event.walletType == CreateWalletType.encryptedXprv) {
          emit(state.copyWith(status: CreateWalletStatus.Imported));
        } else if (event.walletType == CreateWalletType.mnemonic) {
          emit(state.copyWith(status: CreateWalletStatus.Imported));
        } else {
          emit(state.copyWith(status: CreateWalletStatus.CreateImport));
        }
        break;
      case CreateWalletStatus.Reset:
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
        if (event.walletType == CreateWalletType.newWallet) {
          emit(state.copyWith(status: CreateWalletStatus.GenerateMnemonic));
        } else {
          emit(state.copyWith(status: CreateWalletStatus.EnterMnemonic));
        }
        break;
      case CreateWalletStatus.WalletDetail:
        if (event.walletType == CreateWalletType.newWallet) {
          emit(state.copyWith(status: CreateWalletStatus.ConfirmMnemonic));
        } else if (event.walletType == CreateWalletType.encryptedXprv ||
            event.walletType == CreateWalletType.xprv) {
          emit(state.copyWith(status: CreateWalletStatus.EnterEncryptedXprv));
        } else if (event.walletType == CreateWalletType.mnemonic) {
          emit(state.copyWith(status: CreateWalletStatus.EnterMnemonic));
        }
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
        emit(state.copyWith(status: CreateWalletStatus.CreateImport));
        break;
      case CreateWalletStatus.CreateImport:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.Loading:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
      case CreateWalletStatus.LoadingException:
        emit(state.copyWith(status: CreateWalletStatus.Disclaimer));
        break;
    }
  }

  void _generateMnemonicEvent(
      GenerateMnemonicEvent event, Emitter<CreateWalletState> emit) async {
    emit(state.copyWith(
        walletType: event.walletType, status: _getStatus(event)));
  }

  void _verifyXprvEvent(
      VerifyXprvEvent event, Emitter<CreateWalletState> emit) async {
    String xprvStr = event.xprv;

    var errors = ['Invalid Xprv:'];
    if (xprvStr.isEmpty) errors.add('Field is blank');
    if (!xprvStr.startsWith('xprv1')) errors.add('needs to start with "xprv1"');
    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
      ReceivePort resp = ReceivePort();
      cryptoIsolate.send(
          method: 'initializeWallet',
          params: {'walletName': '', 'seed': event.xprv, 'seedSource': 'xprv'});

      Wallet wallet = await resp.first.then((value) {
        return value['wallet'] as Wallet;
      });

      emit(state.copyWith(
          xprvString: event.xprv,
          walletAddress: wallet.externalKeys[0]!.address,
          status: CreateWalletStatus.ValidXprv));
    } catch (e) {}
  }

  void _verifyEncryptedXprvEvent(
      VerifyEncryptedXprvEvent event, Emitter<CreateWalletState> emit) async {
    emit(state.copyWith(status: CreateWalletStatus.Loading));
    try {
      CryptoIsolate cryptoIsolate = Locator.instance<CryptoIsolate>();
      await cryptoIsolate.send(method: 'initializeWallet', params: {
        'walletType': 'hd',
        'walletName': '_loading',
        'seed': event.xprv,
        'seedSource': 'encryptedXprv',
        'password': event.password
      });

      emit(state.copyWith(
        status: CreateWalletStatus.ValidXprv,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: CreateWalletStatus.LoadingException, message: e.toString()));
    }
  }

  void _finishEvent(FinishEvent event, Emitter<CreateWalletState> emit) {
    emit(state.copyWith(status: CreateWalletStatus.Complete));
  }

  void _resetEvent(ResetEvent event, Emitter<CreateWalletState> emit) async {
    emit(state.copyWith(
        walletType: event.walletType, status: _getStatus(event)));
  }

  _getStatus(CreateWalletEvent event) {
    if (event.walletType == CreateWalletType.newWallet) {
      return CreateWalletStatus.Disclaimer;
    }
    if (event.walletType == CreateWalletType.unset) {
      return CreateWalletStatus.CreateImport;
    }
    if (event.walletType == CreateWalletType.reset) {
      return CreateWalletStatus.Reset;
    }
    if (event.walletType == CreateWalletType.imported) {
      return CreateWalletStatus.Imported;
    }
  }
}
