import 'package:bloc/bloc.dart';
import 'package:witnet/explorer.dart' show ValueTransferInfo;
import 'package:witnet_wallet/util/storage/cache/file_manager_interface.dart';

abstract class CacheEvent {}

class InitializeVttCacheEvent extends CacheEvent {}

class AddBatchVttEvent extends CacheEvent {
  AddBatchVttEvent({required this.transactions});
  final List<ValueTransferInfo> transactions;
}

class SaveVttCacheEvent extends CacheEvent {
  SaveVttCacheEvent({required this.transactions});
  final Map<String, ValueTransferInfo> transactions;
}

abstract class CacheState {}

class CacheInitialState extends CacheState {}

class CacheLoadingState extends CacheState {}

class CacheSavingState extends CacheState {}

class CacheLoadedState extends CacheState {}

class CacheInactiveState extends CacheState {}

class CacheErrorState extends CacheState {
  CacheErrorState({required this.exception});
  final exception;
}

class BlocCache extends Bloc<CacheEvent, CacheState> {
  TransactionCache cache = TransactionCache();

  BlocCache(CacheState initialState) : super(initialState);

  @override
  Stream<CacheState> mapEventToState(CacheEvent event) async* {
    try {
      switch (event.runtimeType) {
        case InitializeVttCacheEvent:
          yield CacheLoadingState();
          event as InitializeVttCacheEvent;

          await cache.init();
          yield CacheLoadedState();
          break;
        case SaveVttCacheEvent:
        // TODO:
        case AddBatchVttEvent:
          event as AddBatchVttEvent;
          event.transactions.forEach((vti) async {
            cache.addVtt(vti);
          });
          await cache.updateCache();
      }
    } catch (e) {
      yield CacheErrorState(exception: e);
    }
  }
}

class CacheInterface {}
