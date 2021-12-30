import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/shared/api_auth.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String password;
  LoginEvent({required this.password});
}

class LoginErrorEvent extends AuthEvent {
  final AuthException exception;
  LoginErrorEvent({required this.exception});
}

class LogoutEvent extends AuthEvent {}

class ReadWalletEvent extends AuthEvent {}

class CreateWalletEvent extends AuthEvent {}

class RecoverWalletEvent extends AuthEvent {}

class ResetStateEvent extends AuthEvent {}

class AddWalletEvent extends AuthEvent {}

abstract class AuthState {}

class LoadingLoginState extends AuthState {}

class LoggedInState extends AuthState {
  final DbWallet wallet;

  LoggedInState({
    required this.wallet,
  });
}

class LoadingLogoutState extends AuthState {}

class LoggedOutState extends AuthState {}

class LoginErrorState extends AuthState {
  final AuthException exception;
  LoginErrorState({required this.exception});
}

class CreatingWalletState extends AuthState {}

class LoadingCreateState extends AuthState {}

class LoadedCreateState extends AuthState {}

class ErrorCreateState extends AuthState {}

class RecoverWalletState extends AuthState {}

class LoadingRecoverState extends AuthState {}

class LoadedRecoverState extends AuthState {}

class ErrorRecoverState extends AuthState {}

class AddWalletState extends AuthState {}

class LoadingAddState extends AuthState {}

class LoadedAddState extends AuthState {}

class ErrorAddState extends AuthState {}

Future<bool> _login(String password) async {
  // unlock wallet
  Map<String, dynamic> result = await Locator.instance
      .get<ApiAuth>()
      .unlockWallet(password: password);
  return result['result'];
}



class BlocAuth extends Bloc<AuthEvent, AuthState> {
  BlocAuth(initialState) : super(initialState);
  get initialState => LoggedOutState();

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    try {
      if (event is LoginEvent) {
        /// LoginEvent contains sensitive password data
        yield LoadingLoginState();
        try {
          bool loggedIn = await _login(event.password);
          assert(loggedIn);

          ApiDatabase db =Locator.instance<ApiDatabase>();
          DbWallet dbWallet = await db.loadWallet();

          yield LoggedInState(wallet: dbWallet);

        } on AuthException catch (e) {
          yield LoginErrorState(exception: e);
        }
      } else if (event is LogoutEvent) {
        yield LoadingLogoutState();
        await Locator.instance.get<ApiAuth>().logout();
        yield LoggedOutState();
      } else if (event is CreateWalletEvent) {
        yield LoadingCreateState();
        yield LoadedCreateState();
      } else if (event is LoginErrorEvent) {
        yield LoginErrorState(exception: event.exception);
      } else if (event is ReadWalletEvent) {
      } else {
        yield LoggedOutState();
      }
    } on AuthException catch (e) {
      yield LoginErrorState(exception: e);
    }
  }
}
