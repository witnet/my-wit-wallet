part of 'login_bloc.dart';

enum LoginStatus {
  LoginNotSet,
  LoggedOut,
  LoginInProgress,
  LoginSuccess,
  LoggedIn,
  LoginInvalid,
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.LoggedOut,
    this.password = const Password.pure(),
    required this.message
  });

  final LoginStatus status;
  final Password password;
  final String message;
  LoginState copyWith({
    LoginStatus? status,
    WalletName? walletName,
    Password? password,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      password: password ?? this.password,
      message: message ?? this.message,
    );
  }

  @override
  List<Object> get props => [status, password];
}


