import 'package:cacmp_app/constants/widgets/AppSnackbar.dart';
import 'package:cacmp_app/pages/UserProfilePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:sizer/sizer.dart';

import '../constants/themes/ColorConstants.dart';
import '../stateUtil/AuthController.dart';
import 'LoginPage.dart';
import 'PasswordChangePage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  final AuthController _authController = Get.find();


  @override
  Widget build(BuildContext context) {
    super.build(context);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: kPrimaryColor,
      statusBarIconBrightness: Brightness.light,
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: kPrimaryColor,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.white,
    ));
    return Scaffold(
      backgroundColor: kScaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: SettingsList(
          lightTheme: const SettingsThemeData(
            settingsListBackground: kScaffoldBackgroundColor,
            settingsSectionBackground:Colors.white,
            dividerColor: Colors.black,
            titleTextColor: Colors.black,
            settingsTileTextColor: Colors.black,
            tileDescriptionTextColor: Colors.black54,
            leadingIconsColor: Colors.black54,
          ),
          sections: [
            SettingsSection(
              title: Text(
                'Actions',
                style: TextStyle(
                  fontSize: 15.sp,
                ),
              ),
              tiles: [
                SettingsTile(
                  title: const Text(
                    'Logout',
                  ),
                  description: const Text(
                    'Sign out from the application',
                  ),
                  leading: const Icon(
                    FontAwesomeIcons.arrowRightFromBracket,
                  ),
                  onPressed: (BuildContext context) async {
                    int code = await _authController.logout();
                    if (code == 2000 || code==2003) {
                      Get.offAll(
                        () => const LoginPage(),
                        transition: Transition.leftToRight,
                        curve: Curves.easeInOut,
                        duration: const Duration(
                          milliseconds: 500,
                        ),
                      );
                    }
                    else {
                      AppSnackbar.showSnackbar(title: "Failed to logout", description: "Something went wrong!");
                    }
                  },
                ),
                SettingsTile(
                  title: const Text(
                    'Profile',
                  ),
                  description: const Text(
                    'Manage your profile',
                  ),
                  leading: const Icon(
                    FontAwesomeIcons.user,
                  ),
                  onPressed: (BuildContext context) async {
                  Get.to(()=>const UserProfilePage());
                  },
                ),
                SettingsTile(
                  title: const Text(
                    'Change account password',
                  ),
                  description: const Text(
                    'Change the password for this account!',
                  ),
                  leading: const Icon(
                    FontAwesomeIcons.lock,
                  ),
                  onPressed: (BuildContext context) async {
                    Get.to(()=>const PasswordChangePage());
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
