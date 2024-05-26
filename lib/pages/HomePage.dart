import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cacmp_app/stateUtil/ArticleFeedController.dart';
import 'package:cacmp_app/util/DateFormatUtil.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator2.dart';
import 'ArticleImageCard.dart';
import 'ArticleVideoCard.dart';
import 'ArticlesDetailsPage.dart';
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
    automaticallyImplyLeading: false,
  );

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData({bool isLoadingMore = false}) async {
    final response = await _articleFeedController.loadArticlesFeed(
        isLoadingMore: isLoadingMore);
    if (response == 2003) {
      await _secureStorage.deleteOnLogOut();
      Get.off(() => const LoginPage());
    }
    if (isLoadingMore) {
      _refreshController.loadComplete();
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
    log('loading more...');
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
              body = const CustomLoadingIndicator2(
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
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _articleFeedController.articles.length,
        itemBuilder: (BuildContext context, int index) {
          if (_articleFeedController.articles[index].articleMedia.isEmpty) {
            return InkWell(
              onTap: () {
                Get.to(
                  () => ArticleDetailsPage(
                    article: _articleFeedController.articles[index],
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(
                  top: 5,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.02,
                ),
                alignment: Alignment.centerLeft,
                height: 100,
                width: width,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  title: Text(
                    _articleFeedController.articles[index].title,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        'Published on: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic),
                      ),
                      Text(
                        formatDate(
                          DateTime.parse(
                            _articleFeedController.articles[index].publishDate,
                          ),
                        ),
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            color: Colors.black,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (_articleFeedController
                  .articles[index].articleMedia[0].mediaType ==
              MediaType.image.value) {
            if (_articleFeedController.articles[index].articleMedia.length >
                1) {
              return InkWell(
                onTap: () {
                  Get.to(
                    () => ArticleDetailsPage(
                      article: _articleFeedController.articles[index],
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 5,
                  ),
                  child: ArticleImageCard(
                    article: _articleFeedController.articles[index],
                    height: height,
                    width: width,
                  ),
                ),
              );
            } else {
              log('${_articleFeedController.articles[index].articleMedia.length} index: $index');
              return InkWell(
                onTap: () {
                  Get.to(
                    () => ArticleDetailsPage(
                      article: _articleFeedController.articles[index],
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 5,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 4,
                    child: ListTile(
                      title: Text(
                        _articleFeedController.articles[index].title,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'Published on: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: Colors.black87,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Text(
                            formatDate(
                              DateTime.parse(
                                _articleFeedController.articles[index].publishDate,
                              ),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                        width: 100, // Set the width according to your needs
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: _articleFeedController.articles[index].articleMedia[0].url,
                            placeholder: (context, url) => Container(color: Colors.grey),
                            errorWidget: (context, url, error) => Container(color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  )

                ),
              );
            }
          } else {
            return InkWell(
              onTap: () {
                Get.to(
                  () => ArticleDetailsPage(
                    article: _articleFeedController.articles[index],
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(
                  top: 5,
                ),
                child: ArticleVideoCard(
                  article: _articleFeedController.articles[index],
                  width: width,
                  height: height,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
