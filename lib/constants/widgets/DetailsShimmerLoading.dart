import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetailsShimmerLoading extends StatelessWidget {
  final double height;
  final double width;
  const DetailsShimmerLoading({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: height * 0.2,
              width: width,
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: height * 0.01),
              color: Colors.white,
            ),
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 10, // Number of shimmering items
            itemBuilder: (BuildContext context, int index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: Colors.white,
                  ),
                  title: Container(
                    height: 16,
                    width: 200,
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
