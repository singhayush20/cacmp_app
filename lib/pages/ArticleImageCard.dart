import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

import '../dto/Article.dart';

class ArticleImageCard extends StatefulWidget {
  final Article article;

  const ArticleImageCard({Key? key, required this.article}) : super(key: key);

  @override
  State<ArticleImageCard> createState() => _ArticleImageCardState();
}

class _ArticleImageCardState extends State<ArticleImageCard> {
  List<ImageProvider> _imageProviders = [];
  bool _isPreparingImages = false;
  final PageController _pageController = PageController(initialPage: 0);
  int _activePage = 0;

  @override
  void initState() {
    super.initState();
    // Remove the call to loadImages from initState
    // loadImages(widget.article.articleMedia);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call loadImages from didChangeDependencies instead
    if (!_isPreparingImages && _imageProviders.isEmpty) {
      loadImages(widget.article.articleMedia);
    }
  }

  Future<void> loadImages(List<ArticleMedia> articleMedias) async {
    setState(() {
      _isPreparingImages = true;
    });

    _imageProviders = await Future.wait(articleMedias.map((media) async {
      final imageProvider = NetworkImage(media.url);
      // Preload the image
      await precacheImage(imageProvider, context);
      return imageProvider;
    }).toList());

    setState(() {
      _isPreparingImages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: _calculateAspectRatio(), // Calculate aspect ratio dynamically
              child: Stack(
                alignment: Alignment.center,
                children: [
                  (!_isPreparingImages && _imageProviders.isNotEmpty)
                      ? PageView.builder(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (int page) {
                      setState(() {
                        _activePage = page;
                      });
                    },
                    itemCount: _imageProviders.length,
                    itemBuilder: (context, index) {
                      return Image(image: _imageProviders[index]);
                    },
                  )
                      : _buildShimmerLoading(),
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
                          _imageProviders.length,
                              (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              },
                              child: CircleAvatar(
                                radius: 2,
                                backgroundColor: _activePage == index
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.article.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAspectRatio() {
    // Use a fixed aspect ratio for images
    return 16 / 9;
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
