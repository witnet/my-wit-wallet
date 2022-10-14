part of 'login_bloc.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginLogoutEvent extends LoginEvent {
  LoginLogoutEvent() : super();
}

///
class LoginWalletNameChangedEvent extends LoginEvent {
  const LoginWalletNameChangedEvent(
      {required this.walletName, required this.password})
      : super();

  final WalletName walletName;
  final Password password;
  @override
  List<Object> get props => [walletName];
}

///
class LoginPasswordChangedEvent extends LoginEvent {
  const LoginPasswordChangedEvent(
      {required this.walletName, required this.password})
      : super();

  final WalletName walletName;
  final Password password;

  @override
  List<Object> get props => [walletName, password];
}

class LoginSubmittedEvent extends LoginEvent {
  const LoginSubmittedEvent({required this.walletName, required this.password})
      : super();

  final WalletName walletName;
  final Password password;

  @override
  List<Object> get props => [walletName, password];
}

class LoginExceptionEvent extends LoginEvent {
  final int code;

  final String message;

  const LoginExceptionEvent(WalletName walletName, Password password,
      {required this.code, required this.message})
      : super();

  @override
  List<Object> get props => [code, message];
}
