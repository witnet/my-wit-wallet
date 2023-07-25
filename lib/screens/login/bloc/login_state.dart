part of 'login_bloc.dart';

enum LoginStatus {
  LoginLoading,
  LoggedOut,
  LoginInProgress,
  LoginSuccess,
  LoggedIn,
  LoginInvalid,
  LoginCancelled,
}

class LoginState extends Equatable {
  const LoginState(
      {this.status = LoginStatus.LoggedOut,
      required this.password,
      required this.message});

  final LoginStatus status;
  final String password;
  final String message;
  LoginState copyWith({
    LoginStatus? status,
    WalletName? walletName,
    String? password,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      password: password ?? this.password,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, password, message];
}
