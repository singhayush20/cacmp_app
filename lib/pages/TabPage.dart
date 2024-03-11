import 'package:cacmp_app/pages/ComplaintsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/themes/ColorConstants.dart';
import 'HomePage.dart';
import 'SettingsPage.dart';


class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  final List<Widget> _pages = [
   const HomePage(),
  const ComplaintsPage(),
  const SettingsPage()
  ];

  final List<BottomNavigationBarItem> _items = [
  BottomNavigationBarItem(
      label: "Home",
      icon: const Icon(
        FontAwesomeIcons.house,
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
  @override
  void initState() {
    super.initState();

    _pageController = PageController();

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
      body: PageView(
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        onPageChanged: onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTapped,
        items: _items,
        backgroundColor:
        Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      ),
    );
  }
}
