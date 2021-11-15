import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/dashboard_bloc.dart';
import 'package:witnet_wallet/shared/api_auth.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';

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
  Map<String, Object?> masterNode;
  Map<String, Account> externalAccounts;
  Map<String, Account> internalAccounts;

  LoggedInState({
    required this.masterNode,
    required this.externalAccounts,
    required this.internalAccounts,
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
          // unlock wallet
          await Locator.instance
              .get<ApiAuth>()
              .unlockWallet(password: event.password);
          // get the bip32 masterNode and extended keys
          //await Locator.instance<ApiDatabase>().
          var masterNode = await Locator.instance<ApiDatabase>()
                  .readDatabaseRecord(key: 'master_node', type: Map)
              as Map<String, Object?>;
          var internalAccounts = await Locator.instance<ApiDatabase>()
                  .readDatabaseRecord(key: 'internal_accounts', type: Map)
              as Map<String, Object?>;
          var externalAccounts = await Locator.instance<ApiDatabase>()
                  .readDatabaseRecord(key: 'external_accounts', type: Map)
              as Map<String, Object?>;

          // parse into structure
          Map<String, Account> xt = {};
          externalAccounts.forEach((address, account) {
            account as Map<String, Object?>;
            Account _account = Account.fromJson(account);
            _account.setBalance();
            xt[_account.address] = _account;
          });
          // parse into structure
          Map<String, Account> nt = {};
          internalAccounts.forEach((address, account) {
            account as Map<String, Object?>;
            Account _account = Account.fromJson(account);
            _account.setBalance();
            nt[_account.address] = _account;
            print(_account.utxos);
          });
          yield LoggedInState(
              masterNode: masterNode,
              externalAccounts: xt,
              internalAccounts: nt);
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
