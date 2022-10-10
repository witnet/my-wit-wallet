part of 'login_bloc.dart';


enum LoginStatus {
  LoggedOut,
  LoginInProgress,
  LoginSuccess,
  LoggedIn,
  LoginInvalid,
}

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.LoggedOut,
    this.walletName = const WalletName.pure(),
    this.password = '',
    required this.message
  });

  final LoginStatus status;
  final WalletName walletName;
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
      walletName: walletName ?? this.walletName,
      password: password ?? this.password,
      message: message ?? this.message,
    );
  }
  

  @override
  List<Object> get props => [status, walletName, password];
}


