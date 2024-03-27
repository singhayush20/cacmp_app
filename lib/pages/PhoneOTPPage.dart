import 'dart:developer';

import 'package:cacmp_app/pages/SignUpPage.dart';
import 'package:cacmp_app/stateUtil/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/AppSnackbar.dart';
import '../constants/widgets/CustomLoadingIndicator2.dart';

class PhoneOTPPage extends StatefulWidget {
  final int phone;
  const PhoneOTPPage({super.key, required this.phone});

  @override
  State<PhoneOTPPage> createState() => _PhoneOTPPageState();
}

class _PhoneOTPPageState extends State<PhoneOTPPage> {
  final _appBar = AppBar(
    title: const Text('Sign Up'),
  );

  final AuthController _authController = Get.find();
  String _otp = '';

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
            horizontal: width * 0.05,
          ),
          child: Obx(()=> Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: height * 0.2,
              ),
              Container(
                width: width,
                height: height * 0.1,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter the otp we sent to your phone and click verify',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              OtpTextField(
                numberOfFields: 6,
                enabled: true,
                showCursor: true,
                cursorColor: Colors.tealAccent,
                borderColor: const Color(0xFF512DA8),
                showFieldAsBox: true,
                onCodeChanged: (String code) {

                },
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                enabledBorderColor: kPrimaryColor,
                focusedBorderColor: Colors.black87,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(
                    10,
                  ),
                  bottomRight: Radius.circular(
                    10,
                  ),
                ),
                onSubmit: (String verificationCode) {
                  setState(() {
                    _otp = verificationCode;
                  });
                },
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: ElevatedButton(
                  onPressed:  (_authController.isSendingPhoneOTP.value ||
                      _authController.isVerifyingPhoneOTP.value)
                      ? null
                      : () async {
                    log('verifying otp: $_otp');
                    final code = await _authController.verifyPhoneOTP(
                      otp: int.parse(_otp),);
                    if (code == 2000) {
                      Get.to(() => const SignUp());

                    } else {
                      AppSnackbar.showSnackbar(
                          title: "Wrong otp!",
                          description:
                          "The otp is either incorrect or has expired!");
                    }
                  },
                  child: (_authController.isVerifyingPhoneOTP.value)
                      ? CustomLoadingIndicator2(
                    color: kPrimaryColor,
                    size: 25,
                  )
                      : const Text("Verify"),
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Container(
                height: height * 0.05,
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: (_authController.isSendingPhoneOTP.value ||
                      _authController.isVerifyingPhoneOTP.value)
                      ? null
                      : () async {
                    setState(() {
                      log('clearing otp...');
                      _otp="";
                    });
                    final code = await _authController
                        .sendPhoneVerificationOTP(phoneNum: widget.phone);
                    if (code == 2000) {
                      AppSnackbar.showSnackbar(title: "Sent!", description: "Please check your messages for a new otp",snackPosition: SnackPosition.TOP);
                    } else {
                      AppSnackbar.showSnackbar(
                          title: "Failed!",
                          description: "Cannot send otp at this moment!");
                    }
                  },
                  child: (_authController.isSendingPhoneOTP.value)
                      ? CustomLoadingIndicator2(
                    color: kPrimaryColor,
                    size: 25,
                  )
                      : Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: 15.sp,
                      decoration: TextDecoration.underline,
                      color: Colors.green,
                    ),
                  ),
                ),
              )
            ],
          ),
          ),
        ),
      ),
    );
  }
}
