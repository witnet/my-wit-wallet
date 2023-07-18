import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_wit_wallet/screens/create_wallet/models/wallet_name.dart';
import 'package:my_wit_wallet/shared/api_database.dart';
import 'package:my_wit_wallet/shared/locator.dart';
import 'package:my_wit_wallet/util/storage/database/wallet.dart';

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
