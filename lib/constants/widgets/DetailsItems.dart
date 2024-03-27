import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DetailsItem extends StatelessWidget {
  final String title;
  final String value;
  const DetailsItem({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title: ",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 3,
            child: Text(
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              value,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
