import 'package:flutter/material.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PaginatedData {
  final int totalPages;
  final List data;

  PaginatedData({required this.totalPages, required this.data});
}

class Pagination extends StatefulWidget {
  final Widget child;
  final Function(PaginatedDataArgs)? getPaginatedData;

  Pagination({
    required this.child,
    required this.getPaginatedData,
  });

  PaginationState createState() => PaginationState();
}

enum LoadingDataStatus {
  noMoreData,
  success,
  error,
}

class PaginationState extends State<Pagination> {
  int currentPage = 1;
  late int totalPages = 1;
  RefreshController refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
  }

  LoadingDataStatus loadedDataStatus(PaginatedData? result, int newPage) {
    if (result != null) {
      setState(() {
        currentPage = newPage;
        totalPages = result.totalPages;
      });
      return LoadingDataStatus.success;
    } else {
      return LoadingDataStatus.error;
    }
  }

  Future<LoadingDataStatus> getData({bool isRefresh = false}) async {
    if (isRefresh) {
      // Retrieve first page data
      PaginatedData? result =
          await widget.getPaginatedData!(PaginatedDataArgs(refresh: true));
      return loadedDataStatus(result, 1);
    } else if (currentPage >= totalPages) {
      return LoadingDataStatus.noMoreData;
    } else {
      // Retrieve new page data
      PaginatedData? result = await widget
          .getPaginatedData!(PaginatedDataArgs(currentPage: currentPage));
      return loadedDataStatus(result, currentPage++);
    }
  }

  void setRefresherState(LoadingDataStatus status, bool refresh) {
    switch (status) {
      case LoadingDataStatus.success:
        refresh
            ? refreshController.refreshCompleted()
            : refreshController.loadComplete();
        break;
      case LoadingDataStatus.error:
        refresh
            ? refreshController.refreshFailed()
            : refreshController.loadFailed();
        break;
      case LoadingDataStatus.noMoreData:
        refreshController.loadNoData();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        header: MaterialClassicHeader(
          backgroundColor: WitnetPallet.opacityWhite,
        ),
        footer: ClassicFooter(
            noDataText: 'No more data',
            idleText: 'Pull up to refresh',
            failedText: 'Error loading new data',
            loadingText: 'Loading...',
            loadingIcon: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: theme.textTheme.labelMedium?.color,
                  strokeWidth: 2,
                  value: null,
                  semanticsLabel: 'Circular progress indicator',
                ))),
        onRefresh: () async {
          setRefresherState(await getData(isRefresh: true), true);
        },
        onLoading: () async {
          setRefresherState(await getData(isRefresh: false), false);
        },
        child: widget.child);
  }
}
