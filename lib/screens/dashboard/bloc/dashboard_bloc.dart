import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:witnet_wallet/screens/dashboard/api_dashboard.dart';
import 'package:witnet_wallet/shared/api_database.dart';
import 'package:witnet_wallet/shared/locator.dart';

import 'package:witnet_wallet/util/storage/database/wallet_storage.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  // dbWallet: DbWallet(
  //               externalXpub: null,
  //               internalXpub: null,
  //               xprv: null,
  //               walletName: null,
  //               lastSynced: -1,
  //               walletDescription: '',
  //               externalAccounts: {},
  //               internalAccounts: {}),
  DashboardBloc()
      : super(
          DashboardState(
              walletStorage: WalletStorage(wallets: {}, lastSynced: -1),
              status: DashboardStatus.Loading),
        ) {
    on<DashboardLoadEvent>(_dashboardLoadEvent);
    on<DashboardInitEvent>(_dashboardInitEvent);
    on<DashboardUpdateEvent>(_dashboardUpdateEvent);
    on<DashboardResetEvent>(_dashboardResetEvent);
  }

  get initialState => DashboardState(
      walletStorage: WalletStorage(wallets: {}, lastSynced: -1),
      status: DashboardStatus.Ready);

  Future<void> _dashboardLoadEvent(
    DashboardLoadEvent event,
    Emitter<DashboardState> emit,
  ) async {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    emit(DashboardState(
        walletStorage: apiDashboard.walletStorage!,
        status: DashboardStatus.Ready));
  }

  Future<void> _dashboardInitEvent(
      DashboardInitEvent event, Emitter<DashboardState> emit) async {
    await Future.delayed(Duration(seconds: 4));
    ApiDatabase apiDatabase = Locator.instance<ApiDatabase>();
    WalletStorage walletStorage = await apiDatabase.loadWalletsDatabase();
    emit(DashboardState(
        walletStorage: walletStorage, status: DashboardStatus.Loading));
  }

  Future<void> _dashboardUpdateEvent(
      DashboardUpdateEvent event, Emitter<DashboardState> emit) async {
    ApiDashboard apiDashboard = Locator.instance<ApiDashboard>();
    emit(DashboardState(
        walletStorage: apiDashboard.walletStorage!,
        status: DashboardStatus.Loading));
  }

  void _dashboardResetEvent(
      DashboardResetEvent event, Emitter<DashboardState> emit) {}
}
