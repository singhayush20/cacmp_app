import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/constants/appConstants/AppConstants.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../constants/appConstants/Urls.dart';
import '../util/SecureStorage.dart';

class AuthController extends GetxController {
  final SecureStorage _secureStorage = SecureStorage();

  final _dio = dio.Dio();

  RxBool isLoggingIn = false.obs;
  RxBool isSigningUp = false.obs;
  RxBool isLoggingOut=false.obs;

  Future<int> login(String username, String password) async {
    Map<String, dynamic> data = {
      "username": username,
      "password": password,
    };
    log('logging in: $data url: $loginUrl');
    try {
      isLoggingIn.value = true;
      log("Logging in... $loginUrl $data");
      dio.Response response = await _dio.post(loginUrl, data: data);
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      if (data.isNotEmpty) {
        if (responseData['code'] == 2000) {
          await _secureStorage.writeIsLoggedIn(true);
          await _secureStorage.writeUserToken(responseData['data']['token']);
          await _secureStorage
              .writeAccessToken(
              bearerPrefix + responseData['data']['accessToken']);
          await _secureStorage
              .writeRefreshToken(responseData['data']['refreshToken']);
          await _secureStorage.writeUsername(responseData['data']['username']);
        }
        isLoggingIn.value = false;
        return responseData['code'];
      }
    } catch (e) {
      log(e.toString());
      isLoggingIn.value = false;
      return -1;
    }
    return -1;
  }

  Future<int> signUp({required String name,
    required String email,
    required String password,
    required int phone,
    required String houseNo,
    required String locality,
    required String wardNo,
    required String pinCode,
    required String city,
    required String state,
    required bool isResident,
    required String gender}) async {
    Map<String, dynamic> data = {
      "name": name,
      "email": email,
      "password": password,
      "phone": phone,
      "gender": gender,
      "address": {
        "houseNo": houseNo,
        "locality": locality,
        "wardNo": wardNo,
        "pinCode": pinCode,
        "city": city,
        "state": state,
        "roles": [(isResident) ? "ROLE_RESIDENT" : "ROLE_NON_RESIDENT"]
      }
    };
    try {
      isSigningUp.value = true;
      dio.Response response = await _dio.post(signUpUrl, data: data);
      isSigningUp.value = false;
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      if (data.isNotEmpty) {
        return responseData['code'];
      }
    } catch (e) {
      log(e.toString());
      return -1;
    }
    return -1;
  }

  Future<int> logout() async {

    String? token = await _secureStorage.readAccessToken();
    log('Logging out...');
    try {
      Options options = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: bearerPrefix + token!});
      dio.Response response = await _dio.get(logoutUrl, options: options);
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000 || responseData['code'] == 2003) {
          await _secureStorage.deleteOnLogOut();
        }
        return responseData['code'];
      }
      return -1;
    }
    catch (err) {
      log(err.toString());
      return -1;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _secureStorage.readIsLoggedIn();
  }
}
