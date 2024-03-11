import 'package:cacmp_app/pages/SplashPage.dart';
import 'package:cacmp_app/stateUtil/AuthController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import 'constants/themes/AppTheme.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return Sizer(builder: (context, orientation, deviceTpe) {
      return GetMaterialApp(

        title: 'Flutter Demo',
        theme: themeData,
        darkTheme: themeData,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      );
    });
  }
}
