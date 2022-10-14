import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';
import 'package:witnet_wallet/util/storage/database/db_wallet.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc()
      : super(DashboardState(
            dbWallet: DbWallet(
                externalXpub: null,
                internalXpub: null,
                xprv: null,
                walletName: null,
                lastSynced: -1,
                walletDescription: '',
                externalAccounts: {},
                internalAccounts: {}),
            status: DashboardStatus.Loading)) {
    on<DashboardLoadEvent>(_dashboardLoadEvent);
    on<DashboardInitEvent>(_dashboardInitEvent);
    on<DashboardUpdateEvent>(_dashboardUpdateEvent);
    on<DashboardResetEvent>(_dashboardResetEvent);
  }

  get initialState => DashboardState(
      dbWallet: DbWallet(
          externalXpub: null,
          internalXpub: null,
          xprv: null,
          walletName: null,
          lastSynced: -1,
          walletDescription: '',
          externalAccounts: {},
          internalAccounts: {}),
      status: DashboardStatus.Ready);

  Future<void> _dashboardLoadEvent(
      DashboardLoadEvent event, Emitter<DashboardState> emit) async {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    DbWallet dbWallet = await apiDatabase.loadWallet();

    emit(DashboardState(dbWallet: dbWallet, status: DashboardStatus.Ready));
  }

  Future<void> _dashboardInitEvent(
      DashboardInitEvent event, Emitter<DashboardState> emit) async {
    await Future.delayed(Duration(seconds: 4));
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    DbWallet dbWallet = await apiDatabase.loadWallet();
    emit(DashboardState(dbWallet: dbWallet, status: DashboardStatus.Loading));
  }

  Future<void> _dashboardUpdateEvent(
      DashboardUpdateEvent event, Emitter<DashboardState> emit) async {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    emit(DashboardState(
        dbWallet: apiDashboard.dbWallet!, status: DashboardStatus.Loading));
  }

  void _dashboardResetEvent(
      DashboardResetEvent event, Emitter<DashboardState> emit) {}
}
