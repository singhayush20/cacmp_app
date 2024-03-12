import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cacmp_app/constants/appConstants/Urls.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart%20';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/appConstants/AppConstants.dart';
import '../dto/Category.dart';
import '../util/SecureStorage.dart';

class NewComplaintController extends GetxController {
  final dio.Dio _dio=dio.Dio();
  final _secureStorage = SecureStorage();
  RxBool isLoadingCategories = false.obs;
  final ImagePicker _picker = ImagePicker();
  RxList<Category> categories = RxList<Category>([]);
  Rx<Category> chosenCategory = Category(
    categoryToken: 'null',
    categoryName: 'Choose a category...',
    categoryDescription: '',
  ).obs;
  RxList<XFile> images = <XFile>[].obs;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      images.add(image);
      debugPrint('Picked image: ${image.path}');
      debugPrint('Number of images: ${images.length}');
    }
  }

  Future<void> deleteImage(int index) async {
    debugPrint('Removing image at index: $index');
    images.removeAt(index);
    debugPrint('Number of images: ${images.length}');
  }

  Future<int> loadCategories() async {
    try {
      String? accessToken = await _secureStorage.readAccessToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader:accessToken!},
      );
      dio.Response response = await _dio.get(
        categoriesListUrl,
        options: options,
      );
      isLoadingCategories.value = false;
      Map<String, dynamic> responseData = response.data;
      if (responseData.isNotEmpty) {
        if (responseData['code'] == 2000) {
          List<Category> categoriesList =
          categoriesFromJson(responseData['data']);
          categoriesList.add(chosenCategory.value);
          categories.value = categoriesList;
        }
        return responseData['code'];
      }
    } catch (err) {
      log('$err');
      debugPrintStack();
    }
    return -1;
  }



  Future<int> saveComplaint({
    required String complaintSubject,
    required String complaintDescription,
    required String complaintPriority,
    required String categoryToken,
    required int pinCode,
    required String address,
    required String wardNo,
    required int contactNo,
  }) async {
    try {
      String? accessToken = await _secureStorage.readAccessToken();
      String? userToken = await _secureStorage.readUserToken();
      Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader:accessToken!},
      );


      Map<String, dynamic> complaintData = {
        'complaintSubject': complaintSubject,
        'complaintDescription': complaintDescription,
        'complaintPriority': complaintPriority,
        'categoryToken': categoryToken,
        'pincode': pinCode.toString(),
        'address': address,
        'wardNo': wardNo,
        'contactNo': contactNo.toString(),
        'consumerToken': userToken ?? '',
      };

      log('Saving complaint data: $complaintData to url: $saveComplaintUrl');

      dio.Response response = await _dio.post(saveComplaintUrl, data: complaintData,options: options);
      log('Complaint response data: ${response.data}');
      Map<String, dynamic> responseData = response.data;
      if(responseData.isNotEmpty){
        if(responseData['code']==2000){
          dio.FormData formData=dio.FormData();
          for (int i = 0; i < images.length; i++) {
            XFile image = images[i];
            formData.files.addAll([
              MapEntry("images",await dio.MultipartFile.fromFile(
                image.path,
                filename: 'image_$i.jpg',
              ))
            ]);
          }
          options.contentType=Headers.multipartFormDataContentType;
          dio.Response imageResponse=await _dio.post(saveComplaintImagesUrl, data: formData,options: options,queryParameters: {
            "token": responseData['data']
          });
          Map<String,dynamic> imageSaveResponse=imageResponse.data;
          log('image save response: $imageSaveResponse');
          if(imageSaveResponse.isNotEmpty){
            if(imageSaveResponse['code']==2000){
              return responseData['code'];
            }
          }
        }
        return -1;
      }
    } catch (err) {
      log('$err');
      debugPrintStack();
    }
    return -1;
  }

}

// List<dio.MultipartFile> files=[];

// files.add(await dio.MultipartFile.fromFile(
//   image.path,
//   filename: 'image_$i.jpg',
// ));


// dio.FormData formData=dio.FormData.fromMap({
//   "complaintData": complaintData,
//   "images:": files
// });
