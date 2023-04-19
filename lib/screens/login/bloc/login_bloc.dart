import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'package:witnet_wallet/util/preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc()
      : super(LoginState(
          message: '',
          status: LoginStatus.LoginLoading,
          password: '',
        )) {
    on<LoginSubmittedEvent>(_onSubmitted);
    on<LoginLogoutEvent>(_onLogoutEvent);
    on<LoginDoneLoadingEvent>(_onDoneLoadingEvent);
  }

  void _onSubmitted(LoginSubmittedEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    try {
      emit(state.copyWith(status: LoginStatus.LoginInProgress));
      bool verified = await apiDatabase.verifyPassword(event.password);
      if (verified) {
        String? walletId = await ApiPreferences.getCurrentWallet();
        String? addressIndex =
            await ApiPreferences.getCurrentAddress(walletId!);
        Map<String, dynamic>? addressList =
            await ApiPreferences.getCurrentAddressList();
        apiDatabase.walletStorage.setCurrentWallet(walletId);
        apiDatabase.walletStorage.setCurrentAccount(apiDatabase
            .walletStorage
            .currentWallet
            .externalAccounts[int.parse(addressIndex!.split('/').last)]!
            .address);
        apiDatabase.walletStorage.setCurrentAddressList(
            addressList!.map((key, value) => MapEntry(key, value as String)));
        emit(state.copyWith(status: LoginStatus.LoginSuccess));
      } else {
        emit(state.copyWith(status: LoginStatus.LoginInvalid));
      }
    } catch (e) {
      print('Error submitting $e');
    }
  }

  void _onDoneLoadingEvent(LoginDoneLoadingEvent event, Emitter<LoginState> emit) async {
    emit(state.copyWith(status: LoginStatus.LoggedOut, message: event.walletCount.toString()));
  }

  void _onLogoutEvent(LoginLogoutEvent event, Emitter<LoginState> emit) async {
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    emit(state.copyWith(status: LoginStatus.LoggedOut, message: apiDatabase.walletStorage.wallets.length.toString()));
    await apiDatabase.lockDatabase();
  }
}
