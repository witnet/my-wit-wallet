import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/screens/login/models/password.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
      : super(LoginState(
          message: '',
          status: LoginStatus.LoggedOut,
          password: '',
        )) {
    on<LoginWalletNameChangedEvent>(_onWalletChanged);
    on<LoginPasswordChangedEvent>(_onPasswordChanged);
    on<LoginSubmittedEvent>(_onSubmitted);
    on<LoginExceptionEvent>(_onLoginExceptionEvent);
    on<LoginLogoutEvent>(_onLogoutEvent);
  }

  void _onWalletChanged(
    LoginWalletNameChangedEvent event,
    Emitter<LoginState> emit,
  ) async {
    final WalletName walletName = event.walletName;
    emit(state.copyWith(
      walletName: walletName,
    ));
  }

  void _onPasswordChanged(
      LoginPasswordChangedEvent event, Emitter<LoginState> emit) async {}

  void _onLoginExceptionEvent(
      LoginExceptionEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: LoginStatus.LoggedOut));
  }

  void _onSubmitted(LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();

    try {
      emit(state.copyWith(status: LoginStatus.LoginInProgress));
      bool verified = await apiDatabase.verifyPassword(event.password);
      if (verified) {
        WalletStorage walletStorage = await apiDatabase.loadWalletsDatabase();
        apiDashboard.setWallets(walletStorage);
        emit(state.copyWith(status: LoginStatus.LoginSuccess));
      } else {
        emit(state.copyWith(status: LoginStatus.LoginInvalid));
      }
    } catch (e) {}
  }

  void _onLogoutEvent(LoginLogoutEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    await apiDatabase.lockDatabase();
    emit(state.copyWith(status: LoginStatus.LoggedOut));
  }
}
