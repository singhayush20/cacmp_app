import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/pages/AlertDetailsPage.dart';
import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/stateUtil/AlertController.dart';
import 'package:cacmp_app/util/DateFormatUtil.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/themes/ColorConstants.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage>
    with AutomaticKeepAliveClientMixin {
  final SecureStorage _secureStorage = SecureStorage();
  final AlertController _alertController = Get.find();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _pageNumber = 0; // Current page number

  @override
  void initState() {
    super.initState();
    _fetchAlertData(refresh: true);
  }

  // Function to fetch alert data
  Future<void> _fetchAlertData({bool refresh = false}) async {
    final Map<String, dynamic> requestBody = {
      "pageNumber": _pageNumber,
      "pageSize": 10,
      "sortBy": "publishedOn",
      "sortDirection": "dsc"
    };

    final int statusCode = await _alertController.loadAlerts(
        pagination: requestBody, isRefreshed: refresh);

    if (statusCode == 2000) {
      setState(() {
        if (refresh) {
          _refreshController.refreshCompleted();
        } else {
          _refreshController.loadComplete();
        }
        _pageNumber++;
      });
    } else if (statusCode == 2003) {
      _secureStorage.deleteOnLogOut();
      Get.off(() => const LoginPage());
    }
  }

  // Function to handle refresh
  void _onRefresh() async {
    _pageNumber = 0; // Reset page number
    await _fetchAlertData(refresh: true);
  }

  // Function to handle load more
  void _onLoadMore() async {
    await _fetchAlertData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Alert Page"),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: _onRefresh,
        onLoading: _onLoadMore,
        header: const WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: Colors.teal,
        ),
        // enablePullUp: true,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = const CustomLoadingIndicator(
                color: Colors.tealAccent,
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed! Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = const Text("release to load more");
            } else {
              body = const Text("No more Data");
            }
            return SizedBox(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        child: Obx(
          () => _buildBody(),
        ),
      ),
    );
  }

  // Widget to build body
  Widget _buildBody() {
    if (_alertController.isLoadingAlerts.value &&
        _alertController.alerts.isEmpty) {
      return _buildLoading(); // Show shimmer loading
    } else {
      return _buildAlertList(); // Show alert list
    }
  }

  // Widget to build shimmer loading
  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 10, // Number of shimmer items
      itemBuilder: (context, index) {
        return ListTile(
          title: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 20.0,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // Widget to build alert list
  Widget _buildAlertList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _alertController.alerts.length,
      itemBuilder: (context, index) {
        final alert = _alertController.alerts[index];
        return GestureDetector(
          child: Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert['subject'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published On: ${formatDate(DateTime.parse(alert['publishedOn']))}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            Get.to(() => AlertDetailsPage(alertToken: alert['alertToken']));
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
