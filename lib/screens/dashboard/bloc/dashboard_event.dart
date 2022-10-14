part of 'dashboard_bloc.dart';

class DashboardEvent extends Equatable {
  DashboardEvent({required this.status});

  final DashboardStatus status;

  @override
  List<Object?> get props => [status];
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
