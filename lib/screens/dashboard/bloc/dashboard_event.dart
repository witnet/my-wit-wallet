part of 'dashboard_bloc.dart';

class DashboardEvent extends Equatable {
  final DashboardStatus? status;
  final Wallet? currentWallet;

  DashboardEvent({this.currentWallet, this.status});

  @override
  List<Object?> get props => [currentWallet, status];
}

class DashboardLoadEvent extends DashboardEvent {
  DashboardLoadEvent() : super(status: DashboardStatus.Loading);
}

class DashboardInitEvent extends DashboardEvent {
  DashboardInitEvent() : super(status: DashboardStatus.Initialize);
}

class DashboardUpdateEvent extends DashboardEvent {
  DashboardUpdateEvent() : super(status: DashboardStatus.Synchronizing);
}

class DashboardResetEvent extends DashboardEvent {
  DashboardResetEvent() : super(status: DashboardStatus.Reset);
}

class DashboardUpdateWalletEvent extends DashboardEvent {
  final Wallet? currentWallet;
  DashboardUpdateWalletEvent({this.currentWallet}) : super();
  @override
  List<Object?> get props => [currentWallet];
}
