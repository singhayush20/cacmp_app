import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/appConstants/Urls.dart';
import '../util/SecureStorage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AlertController extends GetxController {
  final SecureStorage _secureStorage = SecureStorage();

  final _dio = dio.Dio();

  RxList<Map<String, dynamic>> alerts = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> alertDetails = <String, dynamic>{}.obs;
  RxBool isLoadingAlerts = false.obs;
  RxBool isLoadingDetails = false.obs;
  Rx<File?> document = Rx<File?>(null);

  Future<int> loadAlerts(
      {required Map<String, dynamic> pagination,
      required bool isRefreshed}) async {
    isLoadingAlerts.value = true;
    String? token = await _secureStorage.readAccessToken();
    log('Loading Alerts...');
    try {
      Options options = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: token!});
      dio.Response response =
          await _dio.get(alertsUrl, data: pagination, options: options);
      isLoadingAlerts.value = false;
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        log('${responseData['data']}');
        if (responseData['code'] == 2000) {
          List<Map<String, dynamic>> list =
              responseData['data'].cast<Map<String, dynamic>>();
          if (isRefreshed) {
            alerts.clear();
          }
          for (var element in list) {
            alerts.add(element);
          }
          return responseData['code'];
        }
        responseData['code'];
      }
      return -1;
    } catch (err) {
      log(err.toString());
      return -1;
    }
  }

  Future<int> loadAlertDetails({required String alertToken}) async {
    String? token = await _secureStorage.readAccessToken();
    isLoadingDetails.value = true;
    Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: token!});
    try {
      dio.Response response = await _dio.get(alertDetailsUrl,
          options: options, queryParameters: {"token": alertToken});

      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000) {
          alertDetails.value = responseData['data'];
          log('${alertDetails['alertDocuments']}');
          File? docFile =
              await _checkForDoc(); // Assign to nullable File variable
          document = Rx<File?>(docFile);

          log('document: ${document.value?.uri.toString()} ${document.value?.path} ${document.value?.path}');
        }
        isLoadingDetails.value = false;
        return responseData['code'];
      }
    } catch (err) {
      log(err.toString());
    }
    isLoadingDetails.value = false;
    return -1;
  }

  Future<File?> _checkForDoc() async {
    if (alertDetails['alertInputType'] == AlertInputType.document.value) {
      if (alertDetails['alertDocuments'] != null &&
          alertDetails['alertDocuments'].length > 0) {
        final response = await http
            .get(Uri.parse(alertDetails['alertDocuments'][0]['documentUrl']));
        final bytes = response.bodyBytes;
        log('file bytes: isEmpty: ${bytes.isEmpty}');
        File? file = await _storeFile(
            alertDetails['alertDocuments'][0]['documentUrl'], bytes);
        return file;
      }
    }
    return null;
  }

  Future<File?> _storeFile(String url, List<int> bytes) async {
    try {
      final filename = alertDetails['alertDocuments'][0]['documentName'];
      final dir = await getApplicationDocumentsDirectory();
      log("file name: $filename application dir: ${dir.path}");
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes, flush: true);
      log(' path of created file: ${file.path}');
      return file;
    } catch (error) {
      log('Error storing file: $error');
      return null; // Return null if file cannot be stored
    }
  }
}
