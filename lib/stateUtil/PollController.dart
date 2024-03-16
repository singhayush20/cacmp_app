import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/constants/appConstants/Urls.dart';
import 'package:cacmp_app/dto/Poll.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../util/SecureStorage.dart';

class PollController extends GetxController {
  RxBool isLoadingPolls = RxBool(false);
  RxBool isSavingVote = RxBool(false);
  RxBool isLoadingPollDetails= RxBool(false);
  RxList<Poll> polls = <Poll>[].obs;
  final SecureStorage _secureStorage = SecureStorage();
  final dio.Dio _dio = dio.Dio();

  Future<int> loadPolls() async {
    isLoadingPolls.value = true;
    try {
      String? accessToken = await _secureStorage.readAccessToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: accessToken!},
      );
      dio.Response response = await _dio.get(pollListUrl, options: options);
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000) {
          isLoadingPolls.value = false;
          polls.value = pollFromJson(responseData['data']);
        }
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isLoadingPolls.value = false;
    }
    return -1;
  }

  Future<Map<String, dynamic>> getPollDetails(
      {required String pollToken}) async {
    try {
      isLoadingPollDetails.value = true;
      String? accessToken = await _secureStorage.readAccessToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: accessToken!},
      );
      dio.Response response = await _dio.get(pollDetailsUrl,
          options: options, queryParameters: {"token": pollToken});
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        return responseData;
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isLoadingPollDetails.value = false;

    }
    return {"code": -1};
  }

  Future<int> castVote({required String pollToken, required choiceToken}) async {
    isSavingVote.value = true;
    _dio.interceptors
        .add(dio.LogInterceptor(requestBody: true, responseBody: true));
    try {
      String? accessToken = await _secureStorage.readAccessToken();
      String? userToken = await _secureStorage.readUserToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: accessToken!},
      );
      log('loading data... $pollListUrl $userToken');
      dio.Response response = await _dio.put(castVoteUrl,
          options: options,
          data: {
            "pollToken": pollToken,
            "pollChoiceToken": choiceToken,
            "consumerToken": userToken
          });
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      isSavingVote.value = false;
      if (responseData.isNotEmpty) {
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isSavingVote.value = false;
    }
    return -1;
  }
}
