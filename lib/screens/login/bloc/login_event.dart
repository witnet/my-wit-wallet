part of 'login_bloc.dart';

class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginLogoutEvent extends LoginEvent {
  LoginLogoutEvent() : super();
}

class LoginSubmittedEvent extends LoginEvent {
  const LoginSubmittedEvent({required this.password}) : super();
  final String password;
  @override
  List<Object> get props => [password];
}

class LoginDoneLoadingEvent extends LoginEvent {
  const LoginDoneLoadingEvent({required this.walletCount}) : super();
  final int walletCount;
  @override
  List<Object> get props => [this.walletCount];
}

