import 'dart:developer';

import 'package:cacmp_app/constants/appConstants/AppConstants.dart';
import 'package:cacmp_app/constants/themes/ColorConstants.dart';
import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/pages/LoginPage.dart';
import 'package:cacmp_app/stateUtil/AlertController.dart';
import 'package:cacmp_app/util/DateFormatUtil.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../constants/widgets/DetailsImageContainer.dart';
import '../constants/widgets/DetailsItems.dart';

class AlertDetailsPage extends StatefulWidget {
  final String alertToken;
  const AlertDetailsPage({super.key, required this.alertToken});

  @override
  State<AlertDetailsPage> createState() => _AlertDetailsPageState();
}

class _AlertDetailsPageState extends State<AlertDetailsPage> {
  final AlertController _alertController = Get.find();
  final SecureStorage _secureStorage = SecureStorage();

  // PDFViewController? controller;
  // int pages = 0;
  // int indexPage = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final int code =
        await _alertController.loadAlertDetails(alertToken: widget.alertToken);
    log('details response code: $code');
    if (code == 2000) {
    } else if (code == 2003) {
      _secureStorage.deleteOnLogOut();
      Get.offAll(() => const LoginPage());
      AppSnackbar.showSnackbar(title: "Expired!", description: "Login again!");
    } else {
      AppSnackbar.showSnackbar(
          title: "Failed!", description: "Cannot load data!");
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

    final height = MediaQuery.of(context).size.height -
        _appBar.preferredSize.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: _appBar,
      body: Obx(
        () => SingleChildScrollView(
          child: (_alertController.isLoadingDetails.value)
              ? CustomLoadingIndicator2(color: kPrimaryColor)
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                  child:
                  // (_alertController
                  //             .alertDetails.value['alertInputType'] ==
                  //         AlertInputType.text.value)
                  //     ?
                  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            (_alertController.alertDetails.value['alertImages']
                                        .length >
                                    0)
                                ? Container(
                                    height: height * 0.3,
                                    width: width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.05,
                                        vertical: height * 0.01),
                                    child: CarouselSlider(
                                      items: _alertController
                                          .alertDetails.value['alertImages']
                                          .map<Widget>((url) {
                                        return DetailsImageContainer(
                                            height: height,
                                            width: width,
                                            imageUrl: url);
                                      }).toList(),
                                      options: CarouselOptions(
                                          autoPlay: false,
                                          aspectRatio: 16 / 9,
                                          enlargeCenterPage: true,
                                          pauseAutoPlayOnTouch: true,
                                          autoPlayInterval:
                                              const Duration(seconds: 3),
                                          autoPlayAnimationDuration:
                                              const Duration(milliseconds: 800),
                                          viewportFraction: 0.8,
                                          onPageChanged: (index, reason) {},
                                          scrollPhysics:
                                              const BouncingScrollPhysics()),
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Details',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  DetailsItem(
                                    title: 'Subject',
                                    value: _alertController
                                        .alertDetails.value['subject'],
                                  ),
                                  DetailsItem(
                                    title: 'Description',
                                    value: _alertController
                                        .alertDetails.value['message'],
                                  ),
                                  DetailsItem(
                                    title: 'Published On',
                                    value: formatDate(DateTime.parse(
                                        _alertController.alertDetails
                                            .value['publishedOn'])),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      // : (_alertController.document.value != null)
                      //     ? Column(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           Container(
                      //             width: width,
                      //             height: height * 0.1,
                      //             alignment: Alignment.centerLeft,
                      //             child: Text(
                      //               'Details',
                      //               style:
                      //                   Theme.of(context).textTheme.bodyLarge,
                      //             ),
                      //           ),
                      //           DetailsItem(
                      //             title: 'Subject',
                      //             value: _alertController
                      //                 .alertDetails.value['subject'],
                      //           ),
                      //           DetailsItem(
                      //             title: 'Published On',
                      //             value: formatDate(DateTime.parse(
                      //                 _alertController
                      //                     .alertDetails.value['publishedOn'])),
                      //           ),
                      //           // Container(
                      //           //   height: height * 0.7,
                      //           //   width: width,
                      //           //   decoration: BoxDecoration(
                      //           //     border: Border.all(color: Colors.black),
                      //           //     color: Colors.red,
                      //           //
                      //           //   ),
                      //           //   child: PDFView(
                      //           //     filePath:
                      //           //         _alertController.document.value!.path,
                      //           //     autoSpacing: false,
                      //           //     swipeHorizontal: true,
                      //           //     pageSnap: false,
                      //           //     pageFling: false,
                      //           //     onRender: (pages) => setState(() {
                      //           //       this.pages = pages ?? 0;
                      //           //       log('rendering... ${this.pages}');
                      //           //     }),
                      //           //     onViewCreated: (controller) => setState(() {
                      //           //       log('view created...');
                      //           //       this.controller = controller;
                      //           //     }),
                      //           //     onPageChanged: (indexPage, _) => setState(
                      //           //         () => this.indexPage = indexPage!),
                      //           //   ),
                      //           // )
                      //         ],
                      //       )
                      //     : Container(),
          ),
        ),
      ),
    );
  }
}
