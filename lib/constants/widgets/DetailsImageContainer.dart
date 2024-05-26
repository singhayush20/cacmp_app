import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

class DetailsImageContainer extends StatelessWidget {
  final String imageUrl;
  const DetailsImageContainer({
    super.key,
    required this.height,
    required this.width,
    required this.imageUrl,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1.0),
        borderRadius: BorderRadius.circular(10),
        color: Colors.black12,
      ),
      child: ZoomOverlay(
        modalBarrierColor: Colors.black12,
        minScale: 0.5,
        maxScale: 3.0,
        animationCurve: Curves.fastOutSlowIn,
        animationDuration: const Duration(milliseconds: 300),
        twoTouchOnly: true,
        // Defaults to false
        onScaleStart: () {},
        // optional VoidCallback
        onScaleStop: () {},
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[50]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              height: height * 0.2,
              width: width,
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.01),
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => Shimmer.fromColors(
            baseColor: Colors.grey[50]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              height: height * 0.2,
              width: width,
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.01),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
