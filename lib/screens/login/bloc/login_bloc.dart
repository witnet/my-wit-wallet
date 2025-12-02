import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:local_auth/local_auth.dart';
import 'package:my_wit_wallet/globals.dart' as globals;

part 'login_event.dart';
part 'login_state.dart';

enum BiometricsStatus {
  autenticated,
  notSupported,
  autenticating,
  error,
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
      : super(LoginState(
          message: '',
          status: LoginStatus.LoginLoading,
          password: '',
        )) {
    on<LoginSubmittedEvent>(_onSubmitted);
    on<LoginAutenticationEvent>(_onBiometricsAutenticate);
    on<LoginLogoutEvent>(_onLogoutEvent);
  }
  final LocalAuthentication auth = LocalAuthentication();

  Future<BiometricsStatus> _onBiometricsAutenticate(
      LoginAutenticationEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    BiometricsStatus status = BiometricsStatus.autenticating;
    try {
      bool isDeviceSupported = await auth.isDeviceSupported();
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      if (isDeviceSupported && canCheckBiometrics) {
        emit(state.copyWith(status: LoginStatus.LoginInProgress));
        globals.biometricsAuthInProgress = true;
        bool authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          persistAcrossBackgrounding: true,
          biometricOnly: true,
        );
        if (authenticated) {
          status = BiometricsStatus.autenticated;
          final currentWalletId = apiDatabase.walletStorage.currentWallet.id;
          await apiDatabase.updateCurrentWallet(
              currentWalletId: currentWalletId);
          emit(state.copyWith(status: LoginStatus.LoginSuccess));
        } else {
          status = BiometricsStatus.error;
          emit(state.copyWith(status: LoginStatus.LoginInvalid));
        }
      } else {
        status = BiometricsStatus.notSupported;
        emit(state.copyWith(status: LoginStatus.BiometricsNotSupported));
      }
      globals.biometricsAuthInProgress = false;
    } on PlatformException catch (error) {
      print('Exception using biometrics authentication $error');
      status = BiometricsStatus.error;
      globals.biometricsAuthInProgress = false;
      emit(state.copyWith(status: LoginStatus.LoginCancelled));
    }
    return status;
  }

  void _onSubmitted(LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    try {
      emit(state.copyWith(status: LoginStatus.LoginInProgress));
      bool verified = await apiDatabase.verifyLogin(event.password);
      if (verified) {
        final currentWallet = apiDatabase.walletStorage.currentWallet;
        await apiDatabase.updateCurrentWallet(
            currentWalletId: currentWallet.id,
            isHdWallet: currentWallet.walletType == WalletType.hd);
        emit(state.copyWith(status: LoginStatus.LoginSuccess));
      } else {
        emit(state.copyWith(status: LoginStatus.LoginInvalid));
      }
    } catch (e) {
      print('Error submitting $e');
    }
  }

  void _onLogoutEvent(LoginLogoutEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    emit(state.copyWith(
        status: LoginStatus.LoggedOut,
        message: apiDatabase.walletStorage.wallets.length.toString()));
    await apiDatabase.lockDatabase();
  }
}
