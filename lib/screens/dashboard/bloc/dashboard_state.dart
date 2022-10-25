part of 'dashboard_bloc.dart';

enum DashboardStatus {
  Ready,
  Loading,
  Initialize,
  Synchronized,
  Synchronizing,
  Reset
}

class DashboardState extends Equatable {
  DashboardState({required this.dbWallet, required this.status});
  final DbWallet dbWallet;
  final DashboardStatus status;

  DashboardState copyWith({
    DbWallet? dbWallet,
    DashboardStatus? status,
  }) {
    return DashboardState(
      dbWallet: dbWallet ?? this.dbWallet,
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [dbWallet, status];
}
