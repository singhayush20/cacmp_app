import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicator2 extends StatelessWidget {
  final Color color;



  const CustomLoadingIndicator2({super.key,
    required this.color,

  });

  @override
  Widget build(BuildContext context) {
    return SpinKitRing(color: color);
  }
}