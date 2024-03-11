import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'ColorConstants.dart';

final ThemeData themeData = ThemeData(
  useMaterial3: false,
  bottomNavigationBarTheme:  BottomNavigationBarThemeData(
    elevation: 4,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    selectedItemColor: kPrimaryColor,
    unselectedItemColor: Colors.black,
    showUnselectedLabels: true,
    showSelectedLabels: true,
    type: BottomNavigationBarType.fixed,
  ),
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      fontSize: 20.sp,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    color: kPrimaryColor,
  ),
  scaffoldBackgroundColor: kScaffoldBackgroundColor,
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 20.sp,
      color: Colors.black,
      fontWeight: FontWeight.w900,
    ),
    bodyLarge: TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w900,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 15.sp,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w500,
      color: Colors.black54,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      backgroundColor: kElevatedButtonColorPrimary,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Colors.green,
      ),
    )
  )
);

InputDecoration inputFormFieldBoxDecoration = InputDecoration(
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(
      color: kTextFieldBorderColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide:  BorderSide(
      color: kPrimaryColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  filled: false,
  prefixIconColor: kPrimaryColor,
  suffixIconColor: kPrimaryColor,
  labelStyle: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontSize: 10.sp,
    height: 0,
  ),
  hintStyle: TextStyle(
    color: Colors.white38,
    fontWeight: FontWeight.w800,
    fontSize: 15.sp,
    height: 0,
  ),
  errorStyle: TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.w500,
    fontSize: 10.sp,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(
      color: Colors.red,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(
      color: Colors.red,
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(
      color: kTextFieldBorderColor,
    ),
  ),
);

InputDecoration inputTextFieldDecoration = InputDecoration(
  enabledBorder: UnderlineInputBorder(
    borderSide: const BorderSide(
      color: kTextFieldBorderColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(
      color: kPrimaryColor,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  filled: false,
  prefixIconColor: kPrimaryColor,
  suffixIconColor: kPrimaryColor,
  labelStyle: TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w800,
    fontSize: 10.sp,
    height: 0,
  ),
  hintStyle: TextStyle(
    color: Colors.white24,
    fontWeight: FontWeight.w800,
    fontSize: 15.sp,
    height: 0,
  ),
  errorStyle: TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.w500,
    fontSize: 10.sp,
  ),
  border: UnderlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(
      color: Colors.red,
    ),
  ),
  errorBorder: UnderlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(
      color: Colors.red,
    ),
  ),
  focusedErrorBorder: UnderlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide:  BorderSide(
      color: kPrimaryColor,
    ),
  ),
);
