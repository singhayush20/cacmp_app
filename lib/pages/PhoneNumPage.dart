import 'package:cacmp_app/constants/themes/ColorConstants.dart';
import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/pages/PhoneOTPPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../constants/themes/AppTheme.dart';
import '../stateUtil/AuthController.dart';

class SignUpPhoneNumPage extends StatefulWidget {
  const SignUpPhoneNumPage({super.key});

  @override
  State<SignUpPhoneNumPage> createState() => _SignUpPhoneNumPageState();
}

class _SignUpPhoneNumPageState extends State<SignUpPhoneNumPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _appBar = AppBar(
    title: const Text('Sign Up'),
  );

  final TextEditingController _phoneNumController = TextEditingController();
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
          child: Obx(
                () => Column(
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
                    'Enter your phone number and we will send you an otp to verify!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneNumController,
                    keyboardType: TextInputType.number,
                    decoration: inputFormFieldBoxDecoration.copyWith(
                      labelText: 'Phone Number',
                      hintText: 'Phone Number',
                      prefixIcon: const Icon(FontAwesomeIcons.phone)
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length!=10) {
                        return "Please enter a valid phone number";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Container(
                  height: height * 0.05,
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                  child: ElevatedButton(
                    onPressed: (_authController.isSendingPhoneOTP.value) ? null :() async{
                      if (_formKey.currentState!.validate()) {
                        final code=await _authController.sendPhoneVerificationOTP(phoneNum: int.parse(_phoneNumController.text));
                        if(code==2000){
                          Get.to(()=>PhoneOTPPage(phone: int.parse(_phoneNumController.text)));
                        }
                        else{
                          AppSnackbar.showSnackbar(title: "Failed!", description: "Cannot send otp at this moment!");
                        }
                      }
                    },
                    child:(_authController.isSendingPhoneOTP.value) ? CustomLoadingIndicator2(color: kPrimaryColor,size: 25,) :const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
