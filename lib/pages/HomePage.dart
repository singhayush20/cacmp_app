import 'dart:developer';

import 'package:cacmp_app/stateUtil/ArticleFeedController.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator.dart';
import 'ArticleImageCard.dart';
import 'ArticleVideoCard.dart';
import 'LoginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ArticleFeedController _articleFeedController = Get.find();
  final SecureStorage _secureStorage = SecureStorage();

  final AppBar _appBar = AppBar(
    title: const Text("Home Page"),
  );

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData({bool isLoadingMore=false}) async {
    final response = await _articleFeedController.loadArticlesFeed(isLoadingMore: isLoadingMore);
    if (response == 2003) {
      await _secureStorage.deleteOnLogOut();
      Get.off(() => const LoginPage());
    }
  }

  void _onRefresh() async {
    try {
      log('refreshing...');
      _fetchData();
    } finally {
      _refreshController.refreshCompleted();
    }
  }

  void _onLoading() async {
    _fetchData(isLoadingMore: true);
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
    final height = MediaQuery.of(context).size.height -
        _appBar.preferredSize.height -
        kBottomNavigationBarHeight;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: _appBar,
      body: SmartRefresher(
        enablePullDown: true,
        header: const WaterDropMaterialHeader(
          color: Colors.white,
          backgroundColor: Colors.teal,
        ),
        enablePullUp: true,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = const Text("...");
            } else if (mode == LoadStatus.loading) {
              body = const CustomLoadingIndicator(
                color: Colors.tealAccent,
              );
            } else if (mode == LoadStatus.failed) {
              body = const Text("Load Failed!Click retry!");
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
        onLoading: _onLoading,
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              key: const Key('List'),
              child: Obx(
                () => _articleFeedController.isLoadingFeed.value
                    ? _buildShimmerLoading()
                    : _buildArticlesList(context, height, width),
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
      itemCount: 5, // Number of shimmering items
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
            ),
            title: Container(
              height: 16,
              width: 200,
              color: Colors.white,
            ),
            subtitle: Container(
              height: 12,
              width: 100,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildArticlesList(BuildContext context, double height, double width) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _articleFeedController.articles.length,
      itemBuilder: (BuildContext context, int index) {
        return (_articleFeedController.articles[index].articleMedia.isEmpty)
            ? Text(_articleFeedController.articles[index].title)
            : (_articleFeedController.articles[index].articleMedia[0].mediaType==MediaType.image.value)
            ? ArticleImageCard(article: _articleFeedController.articles[index])
            : ArticleVideoCard(article: _articleFeedController.articles[index]);
      },
    );

    return Container();
  }
}
