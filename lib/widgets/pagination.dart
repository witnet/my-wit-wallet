import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_wit_wallet/constants.dart';
import 'package:my_wit_wallet/screens/dashboard/view/dashboard_screen.dart';
import 'package:my_wit_wallet/theme/colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PaginatedData {
  final int totalPages;
  final List<dynamic> data;

  PaginatedData({required this.totalPages, required this.data});
}

class Pagination extends StatefulWidget {
  final Widget child;
  final Function(PaginationParams)? getPaginatedData;

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
  late int totalPages;
  RefreshController refreshController = RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
  }

  LoadingDataStatus setLoadedStatus(PaginatedData result, int newPage) {
    setState(() {
      currentPage = newPage;
      totalPages = result.totalPages;
    });
    return LoadingDataStatus.success;
  }

  LoadingDataStatus getData({bool isRefresh = false}) {
    if (isRefresh) {
      // Retrieve first page data
      try {
        PaginatedData result = widget.getPaginatedData!(
            PaginationParams(currentPage: 1, limit: PAGINATION_LIMIT));
        return setLoadedStatus(result, 1);
      } catch (err) {
        return LoadingDataStatus.error;
      }
    } else if (currentPage >= totalPages) {
      return LoadingDataStatus.noMoreData;
    } else {
      int newPage = currentPage + 1;
      // Retrieve new page data
      try {
        PaginatedData result = widget.getPaginatedData!(
            PaginationParams(currentPage: newPage, limit: PAGINATION_LIMIT));
        return setLoadedStatus(result, newPage);
      } catch (err) {
        return LoadingDataStatus.error;
      }
    }
  }

  void setRefresherState(LoadingDataStatus status, bool refresh) {
    switch (status) {
      case LoadingDataStatus.success:
        if (refresh) {
          refreshController.resetNoData();
          refreshController.refreshCompleted();
        } else {
          refreshController.loadComplete();
        }
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
        onRefresh: () {
          setRefresherState(getData(isRefresh: true), true);
        },
        onLoading: () {
          setRefresherState(getData(isRefresh: false), false);
        },
        child: widget.child);
  }
}
