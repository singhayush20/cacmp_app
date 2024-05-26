import 'dart:developer';

import 'package:cacmp_app/util/DateFormatUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../dto/Article.dart';

class ArticleVideoCard extends StatefulWidget {
  final Article article;
  final double width, height;
  const ArticleVideoCard({Key? key, required this.article, required this.width, required this.height}) : super(key: key);

  @override
  State<ArticleVideoCard> createState() => _ArticleVideoCardState();
}

class _ArticleVideoCardState extends State<ArticleVideoCard> {
  List<VideoPlayerController?> _controllers = [];
  bool isPreparingControllers = false;
  final PageController _pageController = PageController(initialPage: 0);
  int _activePage=0;
  @override
  void initState() {
    super.initState();
    initializePlayers(widget.article.articleMedia);
  }

  Future<void> initializePlayers(List<ArticleMedia> articleMedias) async {
    setState(() {
      isPreparingControllers = true;
    });

    _controllers = await Future.wait(articleMedias.map((media) async {
      final fileInfo = await checkCacheFor(media.url);
      if (fileInfo == null) {
        Uri uri = Uri.parse(media.url);
        final controller = VideoPlayerController.networkUrl(uri);
        await controller.initialize();
        return controller;
      } else {
        final file = fileInfo.file;
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        return controller;
      }
    }).toList());

    setState(() {
      isPreparingControllers = false;
    });
  }

  Future<FileInfo?> checkCacheFor(String url) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: widget.width,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: _calculateAspectRatio(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                   (!isPreparingControllers && _controllers.isNotEmpty)?

                    PageView.builder(

                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (int page) {
                        setState(() {
                          if (_controllers[page] != null) {
                            _controllers[page]!.play();
                            _controllers[page]!.setLooping(true);
                            log('is playing... ${_controllers[page]}');
                          }
                          if (_controllers[_activePage] != null) {
                            _controllers[_activePage]!.pause();
                            log('paused... ${_controllers[_activePage]}');
                          }
                          _activePage = page;
                        });
                      },
                      itemCount: _controllers.length,
                      itemBuilder: (context, index) {

                        final controller = _controllers[index];
                        if (controller != null) {

                          return InkWell(
                            onTap: () {
                              if (controller.value.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            },
                            child: VideoPlayer(controller),
                          );
                        } else {
                          return Container(); // or a placeholder widget
                        }
                      },
                    )


                  :
                    _buildShimmerLoading(),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 20,
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                            _controllers.length,
                                (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: InkWell(
                                onTap: () {
                                  _pageController.animateToPage(index,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeIn);
                                },
                                child: CircleAvatar(
                                  radius: 2,
                                  backgroundColor: _activePage == index
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Text(
                    'Published: ${formatDate(DateTime.parse(widget.article.publishDate))}',
                    style:  TextStyle(
                      fontSize: 12.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAspectRatio() {
    if (_controllers.isNotEmpty && _controllers[0] != null) {
      final controller = _controllers[0]!;
      final videoSize = controller.value.size;
      if (videoSize.height != 0) {
        return videoSize.width / videoSize.height;
      }
    }
    return 16 / 9; // Default aspect ratio
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
