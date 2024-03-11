import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/appConstants/Urls.dart';
import '../dto/Complaint.dart';
import '../util/SecureStorage.dart';

class ComplaintController extends GetxController {
  final SecureStorage _secureStorage = SecureStorage();

  final _dio = dio.Dio();
  RxList<Complaint> complaints = <Complaint>[].obs;
  RxBool isLoadingComplaints=false.obs;

  Future<int> loadComplaints() async {
    try {
      isLoadingComplaints.value = true;
      String? accessToken = await _secureStorage.readAccessToken();
      String? userToken = await _secureStorage.readUserToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {
          HttpHeaders.authorizationHeader: bearerPrefix + accessToken!
        },
      );
      Map<String, String> queryParams = {"token": userToken!};
      dio.Response response = await _dio.get(
        listComplaintsUrl,
        options: options,
        queryParameters: queryParams,
      );
      Map<String, dynamic> responseData = response.data;
      isLoadingComplaints.value = false;
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000) {
          List<Complaint> complaintsList = complaintsFromJson(responseData['data']);
          complaints.value = complaintsList;
        }
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    }
    return -1;
  }

}