import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:niimbot_print_example/app/data/commons/constants/ui_constant.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget {

  static Widget listCardLoading({int itemCount = 6}) => ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : MarginSizeConstant.medium),
          child: loadingShimmerCard(
              width: double.maxFinite,
              height: 80
          ),
        );
      }
  );

  static Widget customCircularProgressindicator(
      {double size = 23, double? value, double strokeWidth = 4.0}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        backgroundColor: Get.theme.primaryColor,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: strokeWidth,
        value: value,
      ),
    );
  }

  static Widget loadingShimmerCard(
      {double height = 230,
      double radius = BorderRadiusConstant.low,
      double width = double.maxFinite}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100,
      highlightColor: Colors.grey.shade50,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius))),
        elevation: 0,
        child: SizedBox(height: height, width: width),
      ),
    );
  }

}
