part of 'dashboard_bloc.dart';

class DashboardEvent extends Equatable {
  final DashboardStatus? status;
  final Address? currentAddress;
  final Wallet? currentWallet;

  DashboardEvent({this.currentWallet, this.currentAddress, this.status});

  @override
  List<Object?> get props => [currentWallet, currentAddress, status];
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
  final Address? currentAddress;
  DashboardUpdateWalletEvent({this.currentWallet, this.currentAddress})
      : super();
  @override
  List<Object?> get props => [currentWallet, currentAddress];
}
