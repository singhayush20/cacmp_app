
import 'package:cacmp_app/constants/appConstants/AppConstants.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/stateUtil/UserDataController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/themes/AppTheme.dart';
import '../constants/widgets/AppSnackbar.dart';
import '../util/SecureStorage.dart';
import 'LoginPage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SecureStorage _secureStorage = SecureStorage();
  final UserDataController _userDataController = Get.put(UserDataController());
  final AppBar _appBar = AppBar(
    title: const Text('User Profile'),
  );
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController houseNoController = TextEditingController();
  TextEditingController localityController = TextEditingController();
  TextEditingController wardNoController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  String _chosenGender = Gender.female.value;

  @override
  void initState() {
    super.initState();
    // Fetch user data here
    _fetchUserData();
  }

  void _fetchUserData() async {
    Map<String, dynamic>? userData = await _userDataController.getUserData();
    if (userData['code'] == 2000) {
      setState(() {
        nameController.text = userData['data']['name'];
        emailController.text = userData['data']['email'];
        phoneController.text = userData['data']['phone'];
        _chosenGender = userData['data']['gender'];
        houseNoController.text = userData['data']['houseNo'];
        localityController.text = userData['data']['locality'];
        wardNoController.text = userData['data']['wardNo'];
        pinCodeController.text = userData['data']['pinCode'];
        cityController.text = userData['data']['city'];
        stateController.text = userData['data']['state'];
      });
    } else if (userData['code'] == 2003) {
      _secureStorage.deleteOnLogOut();
      AppSnackbar.showSnackbar(
          title: "Re-login!", description: "You need to login again!");
      Get.off(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height -
        _appBar.preferredSize.height -
        MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: _appBar,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: width * 0.05, vertical: height * 0.01),
          child: (_userDataController.isLoadingData.value)
              ? _buildShimmerLoading()
              : Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: height * 0.1,
                        width: width,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Update your user profile',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'Name',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: emailController,
                              enabled: false,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'Email',
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: phoneController,
                              enabled: false,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'Phone',
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            DropdownButtonFormField<Gender>(
                              value: Gender.male,
                              onChanged: (newValue) {
                                _chosenGender = newValue!.value;
                              },
                              items: <Gender>[
                                Gender.male,
                                Gender.female,
                                Gender.other
                              ].map<DropdownMenuItem<Gender>>((Gender gender) {
                                return DropdownMenuItem<Gender>(
                                  value: gender,
                                  child: Text(gender.value),
                                );
                              }).toList(),
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'Gender',
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: pinCodeController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
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
                              controller: houseNoController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'House No.',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your house no.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: localityController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'Address',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your house no.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: wardNoController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'Ward No',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your ward no.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: cityController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'City',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your city';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: stateController,
                              decoration: inputFormFieldBoxDecoration.copyWith(
                                labelText: 'State',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your state';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              height: height*0.05,
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: (_userDataController
                                        .isUpdating.value)
                                    ? null
                                    : () async {
                                  FocusScope.of(context).unfocus();
                                  if (_formKey.currentState!.validate()) {
                                          final code = await _userDataController
                                              .updateUserDetails(
                                                  name: nameController.text,
                                                  gender: _chosenGender,
                                                  houseNo:
                                                      houseNoController.text,
                                                  locality:
                                                      localityController.text,
                                                  wardNo: wardNoController.text,
                                                  pinCode:
                                                      pinCodeController.text,
                                                  city: cityController.text,
                                                  state: stateController.text);
                                          if (code == 2000) {
                                            Get.back(); //must not be used with Get.snackbar
                                          } else if (code == 2003) {
                                            await _secureStorage
                                                .deleteOnLogOut();
                                            AppSnackbar.showSnackbar(
                                                title: "Re-login!",
                                                description:
                                                    "You need to login again!");
                                            Get.off(() => const LoginPage());
                                          } else {
                                            AppSnackbar.showSnackbar(
                                                title: "Failed!",
                                                description:
                                                    "Failed to submit!");
                                          }
                                        }
                                      },
                                child: (_userDataController.isUpdating.value)
                                    ? const CustomLoadingIndicator2(
                                        color: Colors.white,
                                      )
                                    : const Text('Save'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  bool isNumeric(String value) {
    return double.tryParse(value) != null;
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
}
