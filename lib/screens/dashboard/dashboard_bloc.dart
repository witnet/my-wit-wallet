import 'package:bloc/bloc.dart';
import 'package:witnet_wallet/util/witnet/wallet/account.dart';

abstract class DashboardEvent {}

class DashboardLoadEvent extends DashboardEvent {
  DashboardLoadEvent(
      {required this.externalAccounts, required this.internalAccounts});
  Map<String, Account> externalAccounts;
  Map<String, Account> internalAccounts;
}

class DashboardInitEvent extends DashboardEvent {
  DashboardInitEvent(
      {required this.externalAccounts, required this.internalAccounts});
  Map<String, Account> externalAccounts;
  Map<String, Account> internalAccounts;
}

class DashboardResetEvent extends DashboardEvent {}

abstract class DashboardState {
  Map<String, Account> externalAccounts = {};
  Map<String, Account> internalAccounts = {};
}

class DashboardReadyState extends DashboardState {
  DashboardReadyState(
      {required this.externalAccounts, required this.internalAccounts});
  Map<String, Account> externalAccounts;
  Map<String, Account> internalAccounts;
}

class DashboardLoadingState extends DashboardState {}

class DashboardSynchronizedState extends DashboardState {}

class DashboardSynchronizingState extends DashboardState {}

class BlocDashboard extends Bloc<DashboardEvent, DashboardState> {
  BlocDashboard(DashboardState initialState) : super(initialState);

  get initialState => DashboardLoadingState();

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    try {
      print(event.runtimeType);
      if (event is DashboardLoadEvent) {
        //yield DashboardLoadingState();
        yield DashboardReadyState(
            externalAccounts: event.externalAccounts,
            internalAccounts: event.internalAccounts);
      } else if (event is DashboardInitEvent) {
        print(state.externalAccounts);
        state.externalAccounts.forEach((key, value) {
          print(value);
        });
        await Future.delayed(Duration(seconds: 4));
        yield DashboardLoadingState();
        //yield DashboardReadyState(
        //    externalAccounts: state.externalAccounts,
        //    internalAccounts: state.internalAccounts);

      } else if (event is DashboardResetEvent) {
        yield DashboardLoadingState();
      }
    } catch (e) {
      rethrow;
    }
  }
}
