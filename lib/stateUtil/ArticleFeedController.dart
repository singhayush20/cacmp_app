import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/constants/appConstants/Urls.dart';
import 'package:cacmp_app/dto/Article.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ArticleFeedController extends GetxController {
  RxBool isLoadingFeed = false.obs;

  final dio.Dio _dio = dio.Dio();
  final _secureStorage = SecureStorage();

  RxList<Article> articles=RxList<Article>([]);

  RxInt pageNumber = 0.obs;
  final int pageSize = 10;
  final String sortBy = "createdAt";
  final String sortDirection = "desc";

  Future<int> loadArticlesFeed({ bool isLoadingMore=false}) async {
    if(!isLoadingMore){
      isLoadingFeed.value=true;
      pageNumber.value=0;
    }
    else{
      pageNumber.value++;
    }

    String? accessToken = await _secureStorage.readAccessToken();
    try {
      dio.Options options = dio.Options(
        validateStatus: (_) => true,
        contentType: dio.Headers.jsonContentType,
        responseType: dio.ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: accessToken!},
      );
      Map<String,dynamic> requestBody={
        "pageNumber": pageNumber.value,
        "pageSize": pageSize,
        "sortBy": sortBy,
        "sortDirection": sortDirection
      };
      log('Loading articles for: $requestBody, is loading more: $isLoadingMore');
      final dio.Response response =
          await _dio.get(articleFeedUrl, options: options, data: requestBody);

      Map<String, dynamic> data = response.data;
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000) {
          List<Article> categoriesList =
          articlesFromJson(responseData['data']);
          articles.value = categoriesList;
        }
        return responseData['code'];
      }
    } catch (e) {
      log(e.toString());
    }
finally{
      if(!isLoadingMore){
        isLoadingFeed.value=false;
      }
  }
    return -1;
  }
}
