import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cacmp_app/constants/appConstants/Urls.dart';
import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import '../constants/themes/ColorConstants.dart';

class ComplaintDetailsPage extends StatefulWidget {
  final String token;

  const ComplaintDetailsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<ComplaintDetailsPage> createState() => _ComplaintDetailsPageState();
}

class _ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  Map<String, dynamic> complaintDetails = {};
  List<String> imageUrls = [];
  bool isLoading = false;
  final dio.Dio _dio = dio.Dio();
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
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
        isLoading = false;
      });
    }
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
      body: isLoading
          ? _buildShimmerLoading(height: height, width: width)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: height * 0.3,
                    width: width,
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05, vertical: height * 0.01),
                    child: CarouselSlider(

                      items: imageUrls.map((url) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black12,
                          ),
                          child: ZoomOverlay(
                            modalBarrierColor: Colors.black12,
                            minScale: 0.5,
                            maxScale: 3.0,
                            animationCurve: Curves.fastOutSlowIn,
                            animationDuration: const Duration(milliseconds: 300),
                            twoTouchOnly: true, // Defaults to false
                            onScaleStart: () {}, // optional VoidCallback
                            onScaleStop: () {},
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  height: height * 0.2,
                                  width: width,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.05,
                                      vertical: height * 0.01),
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: height * 0.2,
                                      width: width,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.05,
                                          vertical: height * 0.01),
                                      color: Colors.white,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      }).toList(),
                      options: CarouselOptions(
                        autoPlay: false,
                        aspectRatio: 16 / 9,
                        enlargeCenterPage: true,
                        pauseAutoPlayOnTouch: true,
                        autoPlayInterval: const Duration(seconds: 3),
                        autoPlayAnimationDuration:
                            const Duration(milliseconds: 800),
                        viewportFraction: 0.8,
                        onPageChanged: (index, reason) {},
                        scrollPhysics: const BouncingScrollPhysics()
                      ),
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
                        _buildDetailItem(
                            'Address', complaintDetails['address']),
                        _buildDetailItem('Contact No',
                            complaintDetails['contactNo'].toString()),
                        _buildDetailItem('Complaint\nStatus',
                            complaintDetails['complaintStatus']),
                        _buildDetailItem('Complaint\nPriority',
                            complaintDetails['complaintPriority']),
                        _buildDetailItem('Complaint\nSubject',
                            complaintDetails['complaintSubject']),
                        _buildDetailItem('Complaint\nDescription',
                            complaintDetails['complaintDescription']),
                        _buildDetailItem(
                            'Consumer\nName', complaintDetails['consumerName']),
                        _buildDetailItem('Consumer Phone',
                            complaintDetails['consumerPhone']),
                        _buildDetailItem(
                            'PinCode', complaintDetails['pincode'].toString()),
                        _buildDetailItem('Ward No', complaintDetails['wardNo']),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(top: 10,left: 5,right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex:2,
            child: Text(
              "$title: ",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex:3,
            child: Text(
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              value,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading({required double height, required double width}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height * 0.2,
              width: width,
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.01),
              color: Colors.white,
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 10, // Number of shimmering items
            itemBuilder: (BuildContext context, int index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                  title: Container(
                    height: 16,
                    width: 200,
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}