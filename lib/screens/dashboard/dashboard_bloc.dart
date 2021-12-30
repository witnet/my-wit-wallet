import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/bloc/crypto/crypto_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';

abstract class DashboardEvent {}

class DashboardLoadEvent extends DashboardEvent {
  DashboardLoadEvent(
      {required this.dbWallet});
  DbWallet dbWallet;
}

class DashboardInitEvent extends DashboardEvent {
  DashboardInitEvent(
      {required this.dbWallet});
  DbWallet dbWallet;
}

class DashboardResetEvent extends DashboardEvent {}

abstract class DashboardState {

  DashboardState([this.dbWallet]);
  DbWallet? dbWallet;

}

class DashboardReadyState extends DashboardState {
  DashboardReadyState(DbWallet wallet):super(wallet);
}

class DashboardLoadingState extends DashboardState {
  DashboardLoadingState(DbWallet? wallet):super(wallet);

}

class DashboardSynchronizedState extends DashboardState {
  DashboardSynchronizedState(DbWallet wallet):super(wallet);

}

class DashboardSynchronizingState extends DashboardState {
  DashboardSynchronizingState(DbWallet dbWallet) : super(dbWallet);

}

class BlocDashboard extends Bloc<DashboardEvent, DashboardState> {
  BlocDashboard(DashboardState initialState) : super(initialState);

  get initialState => DashboardLoadingState(null);
  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    try {
      if (event is DashboardLoadEvent) {
        //yield DashboardLoadingState();
        apiDashboard.setDbWallet(event.dbWallet);
        yield DashboardReadyState(event.dbWallet);
      } else if (event is DashboardInitEvent) {
        await Future.delayed(Duration(seconds: 4));
        yield DashboardLoadingState(event.dbWallet);
      } else if (event is DashboardResetEvent) {
        CryptoReadyState();
        apiDashboard.setDbWallet(null);
        yield DashboardLoadingState(null);
      }
    } catch (e) {
      rethrow;
    }
  }
}
