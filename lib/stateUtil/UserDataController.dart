import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../constants/appConstants/Urls.dart';

class UserDataController extends GetxController {
  final SecureStorage _secureStorage = SecureStorage();
  final dio.Dio _dio = dio.Dio();
  RxBool isUpdating = false.obs;
  RxBool isLoadingData = false.obs;

  Future<Map<String, dynamic>> getUserData() async {
    try {
      isLoadingData.value = true;
      String? accessToken = await _secureStorage.readAccessToken();
      String? userToken = await _secureStorage.readUserToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader:accessToken!},
      );
      log('loading data... $userDataUrl $userToken');
      dio.Response response = await _dio.get(userDataUrl,
          options: options, queryParameters: {"token": userToken});
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      if (responseData.isNotEmpty) {
        isLoadingData.value = false;
        return responseData;
      }
    } catch (e) {
      log('$e');
      debugPrintStack();
    }
    return {"code": -1};
  }

  Future<int> updateUserDetails(
      {required String name,
      required String gender,
      required String houseNo,
      required String locality,
      required String wardNo,
      required String pinCode,
      required String city,
      required String state}) async {
    try {
      isUpdating.value = true;
      String? accessToken = await _secureStorage.readAccessToken();
      String? userToken = await _secureStorage.readUserToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader:accessToken!},
      );
      log('data: $name $gender $houseNo $locality $wardNo $pinCode $city $state');
      final Map<String, dynamic> data = {
        "name": name,
        "gender": gender,
        "address": {
          "houseNo": houseNo,
          "locality": locality,
          "wardNo": wardNo,
          "pinCode": pinCode,
          "city": city,
          "state": state
        }
      };
      dio.Response response = await _dio.put(userDataUrl,
          options: options, queryParameters: {"token": userToken}, data: data);
      isUpdating.value = false;
      log('response... ${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000) {}
        return responseData['code'];
      }
    } catch (e) {
      log('$e');
      debugPrintStack();
    }

    return -1;
  }
}
