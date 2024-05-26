import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/constants/appConstants/Urls.dart';
import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/DetailsImageContainer.dart';
import '../constants/widgets/DetailsItems.dart';
import '../constants/widgets/DetailsShimmerLoading.dart';

class ComplaintDetailsPage extends StatefulWidget {
  final String token;

  const ComplaintDetailsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  Map<String, dynamic> complaintDetails = {};
  List<String> imageUrls = [];
  bool _isLoading = false;
  bool _isSavingFeedback = false;
  final TextEditingController _feedbackDescriptionController =
      TextEditingController();
  double _ratingStar = 0;
  final dio.Dio _dio = dio.Dio();
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    fetchData();
    log('isSaving feedback: $_isSavingFeedback');
  }

  Future<void> uploadFeedbackData() async {
    try {
      String? accessToken = await _secureStorage.readAccessToken();
      Options options = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: accessToken});

      Map<String, dynamic> data = {
        "feedbackDescription": _feedbackDescriptionController.text,
        "feedbackRating": "${_ratingStar.floor()}",
        "complaintToken": widget.token
      };

      dio.Response response =
          await _dio.post(saveFeedbackUrl, options: options, data: data);
      log('feedback response: $response.data');
      setState(() {
        _ratingStar = 0;
      });
      _feedbackDescriptionController.clear();

      Map<String, dynamic> responseData = response.data;
      if (responseData['code'] == 2000) {
        Get.back();
        AppSnackbar.showSnackbar(
            title: "Success!", description: "Feedback submitted successfully!");
      } else if (responseData['code'] == 2003) {
        Get.off(() => const LoginPage());
        AppSnackbar.showSnackbar(
            title: "Login!", description: "You need to login again!");
      } else {
        AppSnackbar.showSnackbar(
            title: "Failed!", description: "Failed to save feedback!");
      }
    } catch (err) {
      AppSnackbar.showSnackbar(
          title: "Failed!", description: "Failed to save feedback!");
    }
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String? accessToken = await _secureStorage.readAccessToken();
      final Map<String, dynamic> params = {"token": widget.token};
      Options options = Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {HttpHeaders.authorizationHeader: accessToken});
      final dio.Response response = await _dio.get(complaintDetailsUrl,
          options: options, queryParameters: params);
      final Map<String, dynamic> complaintDetailsResponse = response.data;
      if (complaintDetailsResponse.isNotEmpty) {
        if (complaintDetailsResponse['code'] == 2000) {
          setState(() {
            complaintDetails = complaintDetailsResponse['data'];
          });
        } else if (complaintDetailsResponse['code'] == 2003) {
          await _secureStorage.deleteOnLogOut();
          AppSnackbar.showSnackbar(
              title: "Login required!", description: "Please re-login");
          Get.off(() => const LoginPage());
        }
      }
      final dio.Response imageResponse = await _dio.get(complaintImagesUrl,
          options: options, queryParameters: params);
      final Map<String, dynamic> imageUrlsResponse = imageResponse.data;
      if (imageUrlsResponse.isNotEmpty) {
        if (imageUrlsResponse['code'] == 2000) {
          setState(() {
            imageUrls = List<String>.from(imageUrlsResponse['data']);
          });
        } else if (imageUrlsResponse['code'] == 2003) {
          await _secureStorage.deleteOnLogOut();
          AppSnackbar.showSnackbar(
              title: "Login required!", description: "Please re-login");
          Get.off(() => const LoginPage());
        }
      }
    } catch (err) {
      AppSnackbar.showSnackbar(
          title: "Failed!",
          description: "Failed to fetch data at this moment!");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  final AppBar _appBar = AppBar(
    title: const Text('Details'),
  );

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height -
        _appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: _appBar,
      body: _isLoading
          ? DetailsShimmerLoading(height: height, width: width)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: height * 0.3,
                    width: width,
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.01, vertical: height * 0.01),
                    child: CarouselSlider(
                      items: imageUrls.map<Widget>((url) {
                        return DetailsImageContainer(
                            height: height, width: width, imageUrl: url);
                      }).toList(),
                      options: CarouselOptions(
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          initialPage: 0,
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
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaint Details',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 10),
                        DetailsItem(
                            title: 'Address',
                            value: complaintDetails['address']),
                        DetailsItem(
                            title: 'Contact No',
                            value: complaintDetails['contactNo'].toString()),
                        DetailsItem(
                            title: 'Complaint\nStatus',
                            value: complaintDetails['complaintStatus']),
                        DetailsItem(
                            title: 'Complaint\nPriority',
                            value: complaintDetails['complaintPriority']),
                        DetailsItem(
                            title: 'Complaint\nSubject',
                            value: complaintDetails['complaintSubject']),
                        DetailsItem(
                            title: 'Complaint\nDescription',
                            value: complaintDetails['complaintDescription']),
                        DetailsItem(
                            title: 'Consumer\nName',
                            value: complaintDetails['consumerName']),
                        DetailsItem(
                            title: 'Consumer Phone',
                            value: complaintDetails['consumerPhone']),
                        DetailsItem(
                            title: 'PinCode',
                            value: complaintDetails['pincode'].toString()),
                        DetailsItem(
                            title: 'Ward No',
                            value: complaintDetails['wardNo']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton:
          (!_isLoading && complaintDetails['complaintStatus'] == 'CLOSED')
              ? _getFeedbackFAB()
              : null,
    );
  }

  FloatingActionButton _getFeedbackFAB() {
    return FloatingActionButton.extended(
      label: const Text('Review'),
      onPressed: () {
        log('isSaving feedback... $_isSavingFeedback');
        Get.defaultDialog(
          barrierDismissible: false,
          title: 'Review',
          content: Column(
            children: [
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  _ratingStar = rating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _feedbackDescriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter your review here...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_isSavingFeedback) {
                  log('saving changes triggered...');
                  setState(() {
                    log('saving feedback triggered...');
                    _isSavingFeedback = true;
                  });
                  await uploadFeedbackData();
                  setState(() {
                    log('saving feedback triggered...');
                    _isSavingFeedback = false;
                  });
                }
              },
              child: Text((_isSavingFeedback == false) ? 'Save' : 'Saving...'),
            ),
          ],
        );
      },
      icon: const Icon(
        FontAwesomeIcons.star,
      ),
      backgroundColor: kPrimaryColor,
    );
  }
}
