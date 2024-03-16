import 'dart:developer';

import 'package:cacmp_app/constants/themes/ColorConstants.dart';
import 'package:cacmp_app/pages/PollDetailsPage.dart';
import 'package:cacmp_app/stateUtil/PollController.dart';
import 'package:cacmp_app/util/DateFormatUtil.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import 'LoginPage.dart';

class PollsPage extends StatefulWidget {
  const PollsPage({super.key});

  @override
  State<PollsPage> createState() => _PollsPageState();
}

class _PollsPageState extends State<PollsPage> {
  final AppBar _appBar = AppBar(
    title: const Text('Polls'),
  );

  final PollController _pollController = Get.find();
  final SecureStorage _secureStorage = SecureStorage();
  final RefreshController _refreshController =
  RefreshController(initialRefresh: false);
  @override
  void initState() {
    super.initState();
    _pollController.loadPolls();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onRefresh() async {
    try {
      log('refreshing...');
      final response = await _pollController.loadPolls();
      if (response == 2003) {
        await _secureStorage.deleteOnLogOut();
        Get.off(() => const LoginPage());
      }
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    final response = await _pollController.loadPolls();
    if (response == 2003) {
      await _secureStorage.deleteOnLogOut();
      Get.off(() => const LoginPage());
    }

    _refreshController.loadComplete();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));
    return Scaffold(
      appBar: _appBar,
      body: SmartRefresher(
        enablePullDown: true,
        header: const WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: Colors.teal,
        ),
        enablePullUp: false,

        onLoading: _onLoading,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              key: const Key('List'),
              child: Obx(
                () => _pollController.isLoadingPolls.value
                    ? _buildShimmerLoading()
                    : _buildComplaintsList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16.0,
                  width: 200.0,
                  color: Colors.white,
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 12.0,
                  width: 150.0,
                  color: Colors.white,
                ),
                SizedBox(height: 8.0),
                Container(
                  height: 12.0,
                  width: 100.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildComplaintsList(BuildContext context) {
    return _pollController.polls.isEmpty
        ? Container(
      height: MediaQuery.of(context).size.height * 0.5,
      alignment: Alignment.bottomCenter,
      child: Center(
        child: Text(
          "No Polls Found",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    )
        : ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _pollController.polls.length,
      itemBuilder: (BuildContext context, int index) {
        final poll = _pollController.polls[index];
        return GestureDetector(
          onTap: () {
            Get.to(()=>PollDetailsPage(token: poll.pollToken));
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poll.subject,
                    style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  _buildPollInfo("Description", poll.description),
                  _buildPollInfo("Department", poll.departmentName),
                  _buildPollInfo("Live On", formatDate(poll.liveOn)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPollInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }


  @override
  bool get wantKeepAlive => true;
}
