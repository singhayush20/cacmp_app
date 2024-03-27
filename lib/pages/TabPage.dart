import 'dart:developer';
import 'dart:io';

import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/pages/AlertPage.dart';
import 'package:cacmp_app/pages/ComplaintsPage.dart';
import 'package:cacmp_app/pages/PollsPage.dart';
import 'package:cacmp_app/util/SecureStorage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../constants/appConstants/Urls.dart';
import '../constants/themes/ColorConstants.dart';
import 'HomePage.dart';
import 'LoginPage.dart';
import 'SettingsPage.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final List<Widget> _pages = [
    const HomePage(),
    const AlertPage(),
    const PollsPage(),
    const ComplaintsPage(),
    const SettingsPage()
  ];

  final SecureStorage _secureStorage = SecureStorage();
  final dio.Dio _dio = dio.Dio();

  final List<BottomNavigationBarItem> _items = [
    BottomNavigationBarItem(
      label: "Home",
      icon: const Icon(
        FontAwesomeIcons.house,
      ),
      backgroundColor: kBottomNavigationBarColor,
    ),
    BottomNavigationBarItem(
      label: "Notices",
      icon: const Icon(
        FontAwesomeIcons.fileLines,
      ),
      backgroundColor: kBottomNavigationBarColor,
    ),
    BottomNavigationBarItem(
      label: "Polls",
      icon: const Icon(
        FontAwesomeIcons.squarePollVertical,
      ),
      backgroundColor: kBottomNavigationBarColor,
    ),
    BottomNavigationBarItem(
      label: "Complaints",
      icon: const Icon(
        FontAwesomeIcons.fileContract,
      ),
      backgroundColor: kBottomNavigationBarColor,
    ),
    BottomNavigationBarItem(
      label: "Settings",
      icon: const Icon(
        FontAwesomeIcons.gear,
      ),
      backgroundColor: kBottomNavigationBarColor,
    ),
  ];

  late PageController _pageController;
  int _selectedIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _checkTokenValidity();
  }

  _checkTokenValidity() async {
    setState(() {
      _isLoading = true;
    });
    String? token = await _secureStorage.readAccessToken();
    Options options = Options(
        validateStatus: (_) => true,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {HttpHeaders.authorizationHeader: token!});
    try {
      dio.Response response =
          await _dio.get(tokenValidityUrl, options: options);
      Map<String, dynamic> responseData = response.data;
      log('response: $responseData');
      if (responseData.isNotEmpty) {
        if (responseData['code'] != 2000) {
          await _secureStorage.deleteOnLogOut();
          Get.offAll(() => const LoginPage());
          AppSnackbar.showSnackbar(
              title: "Expired!", description: "Please login again!");
        }
      }
    } catch (err) {
      log(err.toString());
      await _secureStorage.deleteOnLogOut();
      Get.offAll(() => const LoginPage());
      AppSnackbar.showSnackbar(
          title: "Error!", description: "Please login again!");
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : PageView(
              physics: const BouncingScrollPhysics(),
              controller: _pageController,
              onPageChanged: onPageChanged,
              children: _pages,
            ),
      bottomNavigationBar: (_isLoading)
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onTapped,
              items: _items,
              backgroundColor:
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            ),
    );
  }
}
