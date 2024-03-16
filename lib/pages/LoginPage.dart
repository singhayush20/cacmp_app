
import 'package:cacmp_app/pages/SignUpEmailPage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:sizer/sizer.dart';

import '../constants/themes/AppTheme.dart';
import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/AppSnackbar.dart';
import '../constants/widgets/CustomLoadingIndicator2.dart';
import '../stateUtil/AuthController.dart';
import 'TabPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
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
    final height = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.05,
                  ),
                  Container(
                    width: width,
                    height: height * 0.25,
                    color: kScaffoldBackgroundColor,
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                      ),
                      child: Image.asset('assets/login-page.jpg',
                          height: 200, fit: BoxFit.fill),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    height: height * 0.1,
                    width: width,
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Municipal Services\nConsumer Portal',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    height: height * 0.3,
                    // decoration: formFieldBoxDecoration,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Form(
                      key: _formKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: constraints.maxHeight * 0.4,
                                alignment: Alignment.center,
                                child: TextFormField(
                                  controller: _emailController,
                                  obscureText: false,
                                  style: const TextStyle(color: Colors.black),
                                  cursorColor: Colors.black,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Email cannot be empty';
                                    } else if (EmailValidator.validate(
                                            _emailController.text) ==
                                        false) {
                                      return "Enter a valid Email";
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration:
                                      inputFormFieldBoxDecoration.copyWith(
                                    labelText: "Email",
                                    hintText: "Email",
                                    prefixIcon: const Icon(
                                      FontAwesomeIcons.circleUser,
                                    ),
                                  ),
                                ),
                              ),
                              //====PASSWORD====
                              SizedBox(
                                height: constraints.maxHeight * 0.05,
                              ),
                              Container(
                                height: constraints.maxHeight * 0.4,
                                alignment: Alignment.center,
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  cursorColor: Colors.black,
                                  style: const TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Password cannot be empty';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration:
                                      inputFormFieldBoxDecoration.copyWith(
                                    hintText: "Password",
                                    labelText: "Password",
                                    prefixIcon: const Icon(
                                      FontAwesomeIcons.lock,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        (_isPasswordVisible)
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(
                                          () {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.075,
                    width: width * 0.8,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: (_authController.isLoggingIn.value)
                            ? () {}
                            : () {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState!.validate()) {
                                  _authController
                                      .login(_emailController.text,
                                          _passwordController.text)
                                      .then((code) {
                                    if (code == 2000) {
                                      setState(() {
                                        _emailController.clear();
                                        _passwordController.clear();
                                      });
                                      AppSnackbar.showSnackbar(
                                        title: 'Welcome!',
                                        description: 'Login is successful!',
                                      );
                                      Get.off(
                                        () => const TabPage(),
                                        transition: Transition.fadeIn,
                                        curve: Curves.easeInOut,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                      );
                                    } else if (code == 2002) {
                                      AppSnackbar.showSnackbar(
                                        title: 'Login failed!',
                                        description: 'Wrong email or password!',
                                      );
                                    } else {
                                      AppSnackbar.showSnackbar(
                                        title: 'Login failed!',
                                        description: 'Something went wrong!',
                                      );
                                    }
                                  });
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                          ),
                          child: (_authController.isLoggingIn.value)
                              ? const CustomLoadingIndicator2(
                                  color: Colors.white,
                                )
                              : Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    width: width,
                    height: height*0.05,
                    child: TextButton(
                      onPressed: () {
                        Get.to(()=>const SignUpEmailPage());
                      },
                      child: Text('New user? Sign Up',style: TextStyle(fontSize: 15.sp,decoration: TextDecoration.underline , color: Colors.green,),),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
