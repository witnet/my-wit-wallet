part of 'database_bloc.dart';

class DatabaseEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class DatabaseUnlockEvent extends DatabaseEvent {
  DatabaseUnlockEvent({required this.path, required this.password});
  final String path;
  final String password;

  @override
  List<Object> get props => [path, password];
}

class DatabaseLockEvent extends DatabaseEvent {}

class ResetStateEvent extends DatabaseEvent {}

class DatabaseWriteEvent extends DatabaseEvent {
  DatabaseWriteEvent({required this.key, required this.value});
  final key;
  final value;

  @override
  List<Object> get props => [key, value];
}

class DatabaseReadEvent extends DatabaseEvent {
  DatabaseReadEvent(
      {required this.key, required this.type, required this.value});
  final key;
  final Type type;
  final dynamic value;

  @override
  List<Object> get props => [key, type, value];
}
