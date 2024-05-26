import 'dart:developer';

import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/util/DateFormatUtil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart%20';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/DetailsImageContainer.dart';
import '../dto/Article.dart';

class ArticleDetailsPage extends StatefulWidget {
  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  late final WebViewController controller;
  final Dio _dio = Dio();
  bool isLoading = true;
  Map<String, dynamic>? articleData;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    log('Loading article data...');
    Response response = await _dio.get('$requestUrl/article',
        queryParameters: {'slug': widget.article.slug});
    Map<String, dynamic> responseData = response.data;
    log('Article data: $responseData');
    setState(() {
      isLoading = false;
      articleData = responseData['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top;
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
        title: Text(
          widget.article.title,
          overflow: TextOverflow.fade,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: (!isLoading && articleData != null)
              ? Column(
                  children: [
                    Container(
                      height: height * 0.3,
                      width: width,
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01, vertical: height * 0.01),
                      child: CarouselSlider(
                        items: articleData!['articleMedia'].map<Widget>((media) {
                          return DetailsImageContainer(
                              height: height, width: width, imageUrl: media['url']);
                        }).toList(),
                        options: CarouselOptions(
                          enableInfiniteScroll: false,
                            initialPage: 0,
                            autoPlay: false,
                            aspectRatio: 16 / 9,
                            enlargeCenterPage: true,
                            pauseAutoPlayOnTouch: true,
                            autoPlayInterval: const Duration(seconds: 3),
                            autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                            viewportFraction: 0.8,
                            onPageChanged: (index, reason) {},
                            scrollPhysics: const BouncingScrollPhysics()),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Column(
                      children: [
                        ListTile(
                          title: Text('${articleData!['departmentName']}',style: Theme.of(context).textTheme.bodyMedium,),
                          subtitle: Text(formatDateTime(DateTime.parse(articleData!['publishDate'])),style: Theme.of(context).textTheme.bodySmall,),
                        ),
                        const SizedBox(height: 10),
                        Text(articleData!['description']),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(margin:  EdgeInsets.symmetric(horizontal: width * 0.05),child: const Divider(color: Colors.black54, thickness: 1)),
                    const SizedBox(height: 10),

                    Html(
                      data: articleData!['content'],
                      style: {
                        "h1": Style(color: Colors.black),
                        "h2": Style(color: Colors.black),
                        "h3": Style(color: Colors.black),
                        "strong": Style(color: Colors.black),
                      },
                    ),
                  ],
                )
              : CustomLoadingIndicator2(color: kPrimaryColor),
        ),
      ),
    );
  }
}
