import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:witnet_wallet/screens/login/models/password.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

import 'package:witnet_wallet/util/preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
      : super(LoginState(
    message: '',
    status: LoginStatus.LoggedOut,
    password: '',
  )) {
    on<LoginPasswordChangedEvent>(_onPasswordChanged);
    on<LoginSubmittedEvent>(_onSubmitted);
    on<LoginExceptionEvent>(_onLoginExceptionEvent);
    on<LoginLogoutEvent>(_onLogoutEvent);
  }


  void _onPasswordChanged(
      LoginPasswordChangedEvent event, Emitter<LoginState> emit) async {}

  void _onLoginExceptionEvent(
      LoginExceptionEvent event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: LoginStatus.LoggedOut));
  }

  void _onSubmitted(LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    try {
      emit(state.copyWith(status: LoginStatus.LoginInProgress));
      bool verified = await apiDatabase.verifyPassword(event.password);
      if (verified) {
        String? walletId = await ApiPreferences.getCurrentWallet();
        String? addressIndex = await ApiPreferences.getCurrentAddress(walletId!);
        Map<String, dynamic> addressList = await ApiPreferences.getCurrentAddressList();
        apiDatabase.walletStorage.setCurrentWallet(walletId);
        apiDatabase.walletStorage.setCurrentAccount(apiDatabase.walletStorage.currentWallet.externalAccounts[int.parse(addressIndex!.split('/').last)]!.address);
        apiDatabase.walletStorage.setCurrentAddressList(addressList.map((key, value) => MapEntry(key, value as String)));
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
    await apiDatabase.lockDatabase();
    emit(state.copyWith(status: LoginStatus.LoggedOut));
  }
}
