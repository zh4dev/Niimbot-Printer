import 'package:niimbot_print_example/app/data/commons/constants/string_constant.dart';
import 'package:niimbot_print_example/app/data/commons/constants/ui_constant.dart';
import 'package:niimbot_print_example/app/data/commons/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainButtonWidget extends StatelessWidget {
  final String? text;

  final Color? color;
  final Color? textColor;

  final bool? isLoading;
  final bool isDisable;

  final double? height;
  final double? elevation;
  final double? radius;

  final BorderSide? borderSide;
  final Widget? customLeftText;
  final EdgeInsets? padding;
  final Function onPressed;

  const MainButtonWidget(
      {Key? key,
      this.text,
      this.isDisable = false,
      required this.onPressed,
      this.color,
      this.textColor = Colors.white,
      this.radius = BorderRadiusConstant.low,
      this.elevation,
      this.isLoading,
      this.borderSide,
      this.customLeftText,
      this.padding,
      this.height = 45})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (isDisable) return;
        onPressed();
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      color: isDisable ? Get.theme.hintColor : color ?? Get.theme.primaryColor,
      elevation: elevation,
      height: height,
      padding: padding ?? EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(radius ?? BorderRadiusConstant.medium)),
          side: borderSide ?? BorderSide.none),
      child: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 550),
              opacity: isLoading ?? false ? 0.0 : 1.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customLeftText ?? const SizedBox(),
                  SizedBox(
                    width: customLeftText != null
                        ? MarginSizeConstant.small + 2
                        : 0,
                  ),
                  Text(
                    text ?? TextConstant.confirm,
                    style: Get.theme.textTheme.labelLarge!
                        .copyWith(color: textColor),
                  )
                ],
              ),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 550),
              opacity: isLoading ?? false ? 1.0 : 0.0,
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: LoadingWidget.customCircularProgressindicator()),
            ),
          ),
        ],
      ),
    );
  }
}
