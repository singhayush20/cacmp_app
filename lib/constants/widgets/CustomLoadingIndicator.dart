import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sizer/sizer.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final Color color;



  const CustomLoadingIndicator({super.key, 
    required this.color,

  });

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(color: color,size: 10.h);
  }
}