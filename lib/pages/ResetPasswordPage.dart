import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/themes/AppTheme.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator2.dart';
import '../stateUtil/AuthController.dart';
import 'LoginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  final String? email;
  final int? phone;

  const ResetPasswordPage({super.key, this.email, this.phone});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _appBar = AppBar(
    title: const Text('Change password!'),
  );

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthController _authController = Get.find();

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
      appBar: _appBar,
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
                    "Enter the otp we sent on your phone or email along with your new password!",
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
                        controller: _passwordController,
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
                        controller: _confirmPasswordController,
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
                          if (value != _passwordController.text) {
                            return 'Password do not match!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.0.h),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: inputFormFieldBoxDecoration.copyWith(
                          labelText: 'OTP',
                          hintText: 'Enter the otp you received',
                          prefixIcon: const Icon(Icons.pin),
                        ),
                        validator: (value) {
                          if (!isValidOTP(value)) {
                            return "Enter a valid otp";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 4.0.h),
                      ElevatedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            final code = await _authController.changePassword(
                              password: _passwordController.text,
                              otp: int.parse(_otpController.text),
                              email: widget.email,
                              phone: widget.phone,
                            );
                            if(code==2000){
                              Get.off(()=>const LoginPage());
                              AppSnackbar.showSnackbar(title: "Password reset", description: "Your password has been reset successfully!");
                            }
                            else if(code==2002){
                              AppSnackbar.showSnackbar(title: "Failed!", description: "Password reset failed!");
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
