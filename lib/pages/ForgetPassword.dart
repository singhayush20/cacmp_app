import 'package:cacmp_app/constants/themes/ColorConstants.dart';
import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/constants/widgets/CustomLoadingIndicator2.dart';
import 'package:cacmp_app/pages/ResetPasswordPage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constants/appConstants/AppConstants.dart';
import '../constants/themes/AppTheme.dart';
import '../stateUtil/AuthController.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _appBar = AppBar(
    title: const Text('Reset Password'),
  );

  final TextEditingController _textController = TextEditingController();
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
                    'Enter your email or phone number to help us find your account!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: height * 0.05,
                ),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _textController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputFormFieldBoxDecoration.copyWith(
                      labelText: 'Email or Phone',
                      hintText: 'Email or Phone',
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || !EmailValidator.validate(value)) {
                        if( !isValidPhoneNumber(value??'')){
                          return "Please enter a valid email or phone number";
                        }
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
                    onPressed: (_authController.isSendingOTP.value) ? null :() async{
                      if (_formKey.currentState!.validate()) {
                        String? email;
                        int? phone;
                        if(EmailValidator.validate(_textController.text.trim())){
                          email=_textController.text.trim();
                        }
                        else if(isValidPhoneNumber(_textController.text.trim())){
                          phone=int.parse(_textController.text.trim());
                        }
                        final code=await _authController.forgetPassword(email: email, phone: phone);
                        if(code==2000){
                          Get.to(()=>ResetPasswordPage(email: email, phone: phone,));
                        }
                        else{
                          AppSnackbar.showSnackbar(title: "Failed!", description: "Cannot send otp at this moment!");
                        }
                      }
                    },
                    child:(_authController.isSendingOTP.value) ? CustomLoadingIndicator2(color: kPrimaryColor,size: 25,) :const Text('Find Account'),
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
