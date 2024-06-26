import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../constants/themes/AppTheme.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/AppSnackbar.dart';
import '../constants/widgets/CustomLoadingIndicator2.dart';
import '../stateUtil/AuthController.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final AuthController _authController = Get.find();
  late final String userToken;
  final _appBar = AppBar(
    title: const Text('Change password!'),
  );

  @override
  void initState() {
    super.initState();
  }

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
    final height =
        MediaQuery.of(context).size.height - _appBar.preferredSize.height;
    return Scaffold(
      appBar: AppBar(title: const Text("Change password")),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.02,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.15,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Enter the old and new password and click submit!",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _oldPasswordController,
                        obscureText: true,
                        decoration: inputFormFieldBoxDecoration.copyWith(
                          labelText: 'Password',
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.0.h),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: inputFormFieldBoxDecoration.copyWith(
                          labelText: 'Verify Password',
                          hintText: 'Re-enter password',
                          prefixIcon: const Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0.h),
                      ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            final code = await _authController.changeOldPassword(
                              oldPassword: _oldPasswordController.text,
                              newPassword: _newPasswordController.text,
                            );
                            if(code==2000){
                              Get.back();
                              AppSnackbar.showSnackbar(title: "Password reset", description: "Your password has been reset successfully!");
                            }
                            else if(code==2002){
                              AppSnackbar.showSnackbar(title: "Failed!", description: "Please check your current password!");
                            }
                          }
                        },
                        child: (_authController.isSigningUp.value)
                            ? const CustomLoadingIndicator2(
                          color: Colors.white,
                        )
                            : const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
