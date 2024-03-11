import 'package:cacmp_app/stateUtil/NewComplaintController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../constants/themes/ColorConstants.dart';
import '../constants/widgets/CustomLoadingIndicator.dart';
import '../stateUtil/AuthController.dart';
import '../stateUtil/ComplaintController.dart';
import 'LoginPage.dart';
import 'TabPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  final AuthController _loginController = Get.find();
  final ComplaintController _complaintController = Get.put(ComplaintController());
  final NewComplaintController _newComplaintController = Get.put(NewComplaintController());

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(animationController);

    animationController.forward();

    Future.delayed(const Duration(seconds: 5), () async {
      await initializeDateFormatting('en', null);
      if (await _loginController.isLoggedIn()) {
        Get.offAll(
              () => const TabPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeInOut,
          duration: const Duration(
            milliseconds: 500,
          ),
        );
      } else {
        Get.offAll(
              () => const LoginPage(),
          transition: Transition.leftToRight,
          curve: Curves.easeInOut,
          duration: const Duration(
            milliseconds: 500,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade700,
              Colors.teal.shade500,
              Colors.teal.shade300,
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: "heroLogo",
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Image.asset(
                          "assets/icon-image.png",
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Text(
                    "Municipal Services at your doorstep.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Now, you don't have to wait for your complaints to be heard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Positioned(
              bottom: 50.0,
              left: 0,
              right: 0,
              child: CustomLoadingIndicator(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
