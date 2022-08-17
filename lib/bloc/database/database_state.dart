
part of 'database_bloc.dart';

class DatabaseState extends Equatable{

  DatabaseState copyWith(){ return DatabaseState();}

  @override
  List<Object> get props => [];
}

class DatabaseLoadingState extends DatabaseState {}

class DatabaseLoadedState extends DatabaseState {}

class DatabaseUnlockingState extends DatabaseState {}

class DatabaseUnlockedState extends DatabaseState {}

class DatabaseUnlockErrorState extends DatabaseState {}

class InitializingDatabaseState extends DatabaseState {}

class LockingDatabaseState extends DatabaseState {}

class LockedDatabaseState extends DatabaseState {}

class WritingRecordState extends DatabaseState {}

class ReadingRecordState extends DatabaseState {}

class ErrorDatabaseIoState extends DatabaseState {}