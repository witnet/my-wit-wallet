part of 'dashboard_bloc.dart';

class DashboardEvent extends Equatable {
  final DashboardStatus? status;
  final String? currentAddress;
  final String? currentWalletId;
  final String? currentVttId;

  DashboardEvent(
      {this.currentWalletId,
      this.currentAddress,
      this.currentVttId,
      this.status});

  @override
  List<Object?> get props =>
      [currentWalletId, currentAddress, currentVttId, status];
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
  final String? currentAddress;
  final String? currentVttId;
  DashboardUpdateWalletEvent({
    this.currentWallet,
    this.currentAddress,
    this.currentVttId,
  }) : super();
  @override
  List<Object?> get props => [currentWallet, currentAddress, currentVttId];
}
