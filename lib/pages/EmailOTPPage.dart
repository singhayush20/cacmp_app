import 'package:cacmp_app/pages/SignUpPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';

import '../constants/themes/ColorConstants.dart';

class EmailOTPPage extends StatefulWidget {
  final String email;
  const EmailOTPPage({super.key, required this.email});

  @override
  State<EmailOTPPage> createState() => _EmailOTPPageState();
}

class _EmailOTPPageState extends State<EmailOTPPage> {

  final _appBar = AppBar(
    title: const Text('Sign Up'),
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
    final height =
        MediaQuery.of(context).size.height - _appBar.preferredSize.height;
    return Scaffold(
      appBar: _appBar,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
          ),
          child: Column(
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
                  'Enter the otp we sent to your email and click verify',
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
                //runs when a code is typed in
                onCodeChanged: (String code) {
                  //handle validation or checks here
                },
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                enabledBorderColor: kPrimaryColor,
                focusedBorderColor: Colors.black87,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10,),bottomRight: Radius.circular(10,),),
                onSubmit: (String verificationCode){

                }, // end onSubmit
              ),
              SizedBox(
                height: height * 0.05,
              ),

              Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(()=>SignUp(email: widget.email));
                  },
                  child: const Text(
                    "Verify"
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
