import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void showSnackbar({
    required String title,
    required String description,
    Color backgroundColor = Colors.teal,
    Color textColor = Colors.white,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    double borderRadius = 10.0,
    EdgeInsets margin = const EdgeInsets.all(16.0),
    DismissDirection dismissDirection = DismissDirection.horizontal,
    Curve forwardAnimationCurve = Curves.easeOutBack,
    Duration duration = const Duration(seconds: 3),
    SnackStyle snackStyle = SnackStyle.FLOATING,
    Duration animationDuration = const Duration(milliseconds: 500),
    bool isDismissible = true,
    LinearGradient backgroundGradient = const LinearGradient(
      colors: [Colors.teal, Colors.blueAccent],
    ),
    List<BoxShadow> boxShadows = const [
      BoxShadow(
        color: Colors.grey,
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3),
      ),
    ],
    Icon? icon,
  }) {
    Get.snackbar(
      title,
      description,
      backgroundColor: backgroundColor,
      colorText: textColor,
      snackPosition: snackPosition,
      borderRadius: borderRadius,
      margin: margin,
      dismissDirection: dismissDirection,
      forwardAnimationCurve: forwardAnimationCurve,
      duration: duration,
      snackStyle: snackStyle,
      animationDuration: animationDuration,
      isDismissible: isDismissible,
      backgroundGradient: backgroundGradient,
      boxShadows: boxShadows,
      icon: icon,
    );
  }
}