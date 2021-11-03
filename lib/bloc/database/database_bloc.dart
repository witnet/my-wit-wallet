import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

abstract class DatabaseState {}

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

abstract class DatabaseEvent {}

class DatabaseUnlockEvent extends DatabaseEvent {
  DatabaseUnlockEvent({required this.path, required this.password});
  final String path;
  final String password;
}

class DatabaseLockEvent extends DatabaseEvent {}

class ResetStateEvent extends DatabaseEvent {}

class DatabaseWriteEvent extends DatabaseEvent {
  DatabaseWriteEvent({required this.key, required this.value});
  final key;
  final value;
}

class DatabaseReadEvent extends DatabaseEvent {
  DatabaseReadEvent({required this.key, required this.type});
  final key;
  final Type type;
  late dynamic value;
}

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  DatabaseBloc(DatabaseState initialState) : super(initialState);
  get initialState => LockedDatabaseState();
  @override
  Stream<DatabaseState> mapEventToState(DatabaseEvent event) async* {
    /// unlock / decrypt the database
    if (event is DatabaseUnlockEvent) {
      try {
        yield DatabaseUnlockingState();
        bool unlocked = await Locator.instance
            .get<ApiDatabase>()
            .unlockDatabase(name: event.path, password: event.password);
        yield (unlocked) ? DatabaseUnlockedState() : DatabaseUnlockErrorState();
      } catch (e) {
        yield DatabaseUnlockErrorState();
      }
    }

    /// lock / nullify the database
    else if (event is DatabaseLockEvent) {
      yield LockingDatabaseState();

      /// lock the database clears/nullifies the database instance.
      /// the actual file stays encrypted at runtime.
      await Locator.instance.get<ApiDatabase>().lockDatabase();
      yield LockedDatabaseState();

      /// write record to database
    }

    /// write record to wallet database
    else if (event is DatabaseWriteEvent) {
      yield WritingRecordState();
      await Locator.instance
          .get<ApiDatabase>()
          .writeDatabaseRecord(key: event.key, value: event.value);
      yield DatabaseUnlockedState();
    }

    /// read record from wallet database
    else if (event is DatabaseReadEvent) {
      yield ReadingRecordState();
      await Locator.instance
          .get<ApiDatabase>()
          .readDatabaseRecord(key: event.key, type: event.type);
      yield DatabaseUnlockedState();
    } else if (event is ResetStateEvent) {}
  }
}
