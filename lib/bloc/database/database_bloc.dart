import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

part 'database_event.dart';
part 'database_state.dart';

class DatabaseBloc extends Bloc<DatabaseEvent, DatabaseState> {
  DatabaseBloc(DatabaseState initialState) : super(initialState) {
    on<DatabaseUnlockEvent>(_databaseUnlockEvent);
    on<DatabaseLockEvent>(_databaseLockEvent);
    on<DatabaseReadEvent>(_databaseReadEvent);
    on<DatabaseWriteEvent>(_databaseWriteEvent);
  }

  get initialState => LockedDatabaseState();
}

/// unlock / decrypt the database
Future<void> _databaseUnlockEvent(
    DatabaseUnlockEvent event, Emitter<DatabaseState> emit) async {
  try {
    emit(DatabaseUnlockingState());
    bool unlocked = await Locator.instance
        .get<ApiDatabase>()
        .unlockDatabase(name: event.path, password: event.password);
    emit((unlocked) ? DatabaseUnlockedState() : DatabaseUnlockErrorState());
  } catch (e) {
    emit(DatabaseUnlockErrorState());
  }
}

/// lock / nullify the database
Future<void> _databaseLockEvent(
    DatabaseLockEvent event, Emitter<DatabaseState> emit) async {
  /// lock the database clears/nullifies the database instance.
  /// the actual file stays encrypted at runtime.
  emit(LockingDatabaseState());
  await Locator.instance.get<ApiDatabase>().lockDatabase();
  emit(LockedDatabaseState());
}

/// write record to wallet database
Future<void> _databaseWriteEvent(
    DatabaseWriteEvent event, Emitter<DatabaseState> emit) async {
  emit(WritingRecordState());
  await Locator.instance
      .get<ApiDatabase>()
      .writeDatabaseRecord(key: event.key, value: event.value);
  emit(DatabaseUnlockedState());
}

/// read record from wallet database
Future<void> _databaseReadEvent(
    DatabaseReadEvent event, Emitter<DatabaseState> emit) async {
  emit(ReadingRecordState());
  await Locator.instance
      .get<ApiDatabase>()
      .readDatabaseRecord(key: event.key, type: event.type);
  emit(DatabaseUnlockedState());
}
