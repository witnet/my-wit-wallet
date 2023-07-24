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

class LoginAutenticationEvent extends LoginEvent {
  LoginAutenticationEvent() : super();
}
