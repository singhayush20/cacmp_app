import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/constants/appConstants/AppConstants.dart';
import 'package:cacmp_app/constants/themes/AppTheme.dart';
import 'package:cacmp_app/dto/Category.dart';
import 'package:cacmp_app/stateUtil/NewComplaintController.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/AppSnackbar.dart';
import 'LoginPage.dart';

class NewComplaintsPage extends StatefulWidget {
  const NewComplaintsPage({Key? key}) : super(key: key);

  @override
  State<NewComplaintsPage> createState() => _NewComplaintsPageState();
}

class _NewComplaintsPageState extends State<NewComplaintsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _wardNoController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  ComplaintPriority _complaintPriority = ComplaintPriority.low;
  final SecureStorage _secureStorage = SecureStorage();
  final NewComplaintController _newComplaintController =
      NewComplaintController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a new issue'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<int>(
              future: _newComplaintController.loadCategories(),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == 2000) {
                    return Column(
                      children: [
                        Obx(
                          () => SizedBox(
                              height: height * 0.4,
                              width: width,
                              child: (_newComplaintController.images.isEmpty)
                                  ? GestureDetector(
                                      onTap: () {},
                                      child:
                                          Image.asset("assets/pick-image.jpg"),
                                    )
                                  : CarouselSlider(
                                      items: _newComplaintController.images
                                          .map((image) {
                                        return Stack(
                                          children: [
                                            Container(
                                              height: height * 0.4,
                                              width: width * 0.95,
                                              color: Colors.white60,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 0,
                                              ),
                                              child: Image.file(
                                                File(image.path),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: IconButton(
                                                onPressed: () =>
                                                    _newComplaintController
                                                        .deleteImage(
                                                            _newComplaintController
                                                                .images
                                                                .indexOf(
                                                                    image)),
                                                icon: const Icon(Icons.close),
                                              ),
                                            ),
                                          ],
                                        );
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
                                          enableInfiniteScroll: false),
                                    ) //show carousel slider for more than 1 image
                              ),
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: width * 0.4,
                          child: ElevatedButton(
                            onPressed: () async {
                              await _newComplaintController.pickImage();
                            },
                            child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Icon(FontAwesomeIcons.camera),
                                  Text('Add Image'),
                                ]),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _subjectController,
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Subject',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a subject';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 3, // Allow multiple lines
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Description',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              DropdownButtonFormField<ComplaintPriority>(
                                value: _complaintPriority,
                                onChanged: (newValue) {
                                  setState(() {
                                    _complaintPriority = newValue!;
                                  });
                                },
                                items: <ComplaintPriority>[
                                  ComplaintPriority.low,
                                  ComplaintPriority.medium,
                                  ComplaintPriority.high
                                ].map<DropdownMenuItem<ComplaintPriority>>(
                                    (ComplaintPriority complaintPriority) {
                                  return DropdownMenuItem<ComplaintPriority>(
                                    value: complaintPriority,
                                    child: Text(complaintPriority.value),
                                  );
                                }).toList(),
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Priority',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              DropdownButtonFormField<Category>(
                                value: _newComplaintController
                                    .chosenCategory.value,
                                onChanged: (newValue) {
                                  setState(() {
                                    _newComplaintController
                                        .chosenCategory.value = newValue!;
                                  });
                                },
                                items: _newComplaintController.categories
                                    .map<DropdownMenuItem<Category>>(
                                        (Category category) {
                                  return DropdownMenuItem<Category>(
                                    value: category,
                                    child: Text(category.categoryName),
                                  );
                                }).toList(),
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Category',
                                ),
                                validator: (value) {
                                  if (value!.categoryName ==
                                      'Choose a category...') {
                                    return 'Choose a category';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _addressController,
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Location',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a location';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _wardNoController,
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Ward No.',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a ward no.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              TextFormField(
                                controller: _pinCodeController,
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'PinCode',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a PinCode';
                                  } else if (!isNumeric(value)) {
                                    return 'Please enter a valid pinCode';
                                  }
                                  if (value.length != 6) {
                                    return 'Please enter a valid pinCode';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),

                              TextFormField(
                                controller: _contactNoController,
                                decoration:
                                    inputFormFieldBoxDecoration.copyWith(
                                  labelText: 'Contact No.',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a contact no.';
                                  } else if (!isNumeric(value)) {
                                    return 'Please enter a valid contact no.';
                                  }
                                  if (value.length != 10) {
                                    return 'Please enter a valid mobile no.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16.0),
                              Container(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final int code = await _newComplaintController
                                          .saveComplaint(
                                              complaintSubject:
                                                  _subjectController.text,
                                              complaintDescription:
                                                  _descriptionController.text,
                                              complaintPriority:
                                                  _complaintPriority.value,
                                              categoryToken:
                                                  _newComplaintController
                                                      .chosenCategory
                                                      .value
                                                      .categoryToken,
                                              pinCode: int.parse(
                                                  _pinCodeController.text),
                                              address: _addressController.text,
                                              wardNo: _wardNoController.text,
                                              contactNo: int.parse(
                                                  _contactNoController.text));
                                      if (code == 2000) {
                                        Get.back();
                                        AppSnackbar.showSnackbar(
                                            title: "Successful",
                                            description:
                                            "Your complaint has been submitted!");
                                      } else if (code == 2003) {
                                        await _secureStorage.deleteOnLogOut();
                                        AppSnackbar.showSnackbar(
                                            title: "Re-login!",
                                            description:
                                                "You need to login again!");
                                        Get.off(() => const LoginPage());
                                      } else {
                                        AppSnackbar.showSnackbar(
                                            title: "Failed!",
                                            description: "Failed to submit!");
                                      }
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.data == 2003) {
                    _secureStorage.deleteOnLogOut();
                    AppSnackbar.showSnackbar(
                        title: "Login required!",
                        description: "Please re-login");
                    Get.offAll(() => const LoginPage());
                  } else {
                    return _buildShimmerLoading();
                  }
                }
                return _buildShimmerLoading();
              }),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 8, // Number of shimmering items
      itemBuilder: (BuildContext context, int index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            title: Container(
              height: 20,
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
    );
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
