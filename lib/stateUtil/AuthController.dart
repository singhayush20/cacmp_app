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
  RxString signupEmail = ''.obs; //email for signup
  RxInt signupPhone = 0.obs;
  final _dio = dio.Dio();

  RxBool isLoggingIn = false.obs;
  RxBool isSigningUp = false.obs;
  RxBool isLoggingOut = false.obs;
  RxBool isSendingOTP = false.obs;
  RxBool isVerifyingOTP = false.obs;
  RxBool isSendingPhoneOTP = false.obs;
  RxBool isVerifyingPhoneOTP = false.obs;
  RxBool isChangingPassword = false.obs;

  Future<int> sendEmailVerificationOTP({required String email}) async {
    isSendingOTP.value = true;
    log('sending otp to $email');
    try {
      final dio.Response response = await _dio
          .get(emailVerificationUrl, queryParameters: {"email": email});
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        signupEmail.value = email;
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isSendingOTP.value = false;
    }
    return -1;
  }

  Future<int> verifyEmailOTP({required int otp}) async {
    isVerifyingOTP.value = true;
    try {
      final dio.Response response = await _dio.get(emailVerificationOtpUrl,
          queryParameters: {"email": signupEmail.value, "otp": otp});
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isVerifyingOTP.value = false;
    }
    return -1;
  }

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
          await _secureStorage.writeAccessToken(
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

  Future<int> signUp(
      {required String name,
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
        "state": state
      },
      "roles": [(isResident) ? "ROLE_RESIDENT" : "ROLE_NON_RESIDENT"]
    };
    try {
      isSigningUp.value = true;
      log('sign up data: $data');
      dio.Response response = await _dio.post(signUpUrl, data: data);
      isSigningUp.value = false;
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      if (data.isNotEmpty) {
        return responseData['code'];
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isSigningUp.value = false;
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
          headers: {HttpHeaders.authorizationHeader: token!});
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
    } catch (err) {
      log(err.toString());
      return -1;
    }
  }

  Future<bool> isLoggedIn() async {
    return await _secureStorage.readIsLoggedIn();
  }

  Future<int> sendPhoneVerificationOTP({required int phoneNum}) async {
    isSendingPhoneOTP.value = true;
    log('sending otp to $phoneNum');
    try {
      final dio.Response response = await _dio
          .get(phoneVerificationOtoUrl, queryParameters: {"phone": phoneNum});
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        signupPhone.value = phoneNum;
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isSendingPhoneOTP.value = false;
    }
    return -1;
  }

  Future<int> verifyPhoneOTP({required int otp}) async {
    isVerifyingPhoneOTP.value = true;
    try {
      final dio.Response response = await _dio.get(phoneVerificationOtpUrl,
          queryParameters: {"phone": signupPhone.value, "otp": otp});
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isVerifyingPhoneOTP.value = false;
    }
    return -1;
  }

  Future<int> forgetPassword({String? email, int? phone}) async {
    isSendingOTP.value = true;
    log('sending otp to email: $email phone: $phone url: $passwordForgetUrl');
    try {
      final dio.Response response = await _dio.get(passwordForgetUrl,
          queryParameters: {"email": email, "phone": phone});
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isSendingOTP.value = false;
    }
    return -1;
  }

  Future<int> changePassword(
      {required String password,
      String? email,
      int? phone,
      required int otp}) async {
    isVerifyingOTP.value = true;
    try {
      final dio.Response response = await _dio.put(passwordChangeUrl, data: {
        "password": password,
        "email": email,
        "phone": phone,
        "otp": otp
      });
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    } finally {
      isVerifyingOTP.value = false;
    }
    return -1;
  }

  Future<int> changeOldPassword(
      {required String oldPassword, required String newPassword}) async {
    isChangingPassword.value = true;
    try {
      String? token = await _secureStorage.readAccessToken();
      Options options = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: token!});
      final dio.Response response = await _dio.put(changeOldPasswordUrl,
          data: {
            "oldPassword": oldPassword,
            "newPassword": newPassword,
            "consumerToken": await _secureStorage.readUserToken()
          },
          options: options);
      log('${response.data}');
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    }
    return -1;
  }
}
