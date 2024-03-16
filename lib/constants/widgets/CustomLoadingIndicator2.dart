import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicator2 extends StatelessWidget {
  final Color color;
  final double size;

  const CustomLoadingIndicator2(
      {super.key, required this.color, this.size = 25});

  @override
  Widget build(BuildContext context) {
    return SpinKitRing(
      color: color,
      size: size,
      lineWidth: 2,
    );
  }
}
