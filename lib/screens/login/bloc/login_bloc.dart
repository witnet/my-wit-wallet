import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';
import 'package:local_auth/local_auth.dart';

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
    on<LoginDoneLoadingEvent>(_onDoneLoadingEvent);
  }
  final LocalAuthentication auth = LocalAuthentication();

  Future<BiometricsStatus> _onBiometricsAutenticate(
      LoginAutenticationEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    BiometricsStatus status = BiometricsStatus.autenticating;
    try {
      bool isDeviceSupported = await auth.isDeviceSupported();
      if (isDeviceSupported) {
        emit(state.copyWith(status: LoginStatus.LoginInProgress));
        bool authenticated = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
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
    } on PlatformException catch (error) {
      print('Exception using biometrics authentication $error');
      status = BiometricsStatus.error;
      emit(state.copyWith(status: LoginStatus.LoginCancelled));
    }
    return status;
  }

  void _onSubmitted(LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    try {
      emit(state.copyWith(status: LoginStatus.LoginInProgress));
      bool verified = await apiDatabase.verifyPassword(event.password);
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

  void _onDoneLoadingEvent(
      LoginDoneLoadingEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(
        status: LoginStatus.LoggedOut, message: event.walletCount.toString()));
  }

  void _onLogoutEvent(LoginLogoutEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    emit(state.copyWith(
        status: LoginStatus.LoggedOut,
        message: apiDatabase.walletStorage.wallets.length.toString()));
    await apiDatabase.lockDatabase();
  }
}
