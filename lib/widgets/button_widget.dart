/*
 * @Author GS
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:location1/colors.dart';
import 'package:provider/provider.dart';

import 'loading_animation_controller.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool expanded;
  final bool enabled;
  final String title;
  final Color color;
  final Color backgroundColor;
  final double loaderSize;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final TextDecoration? textDecoration;
  final TextDecorationStyle? textDecorationStyle;
  final double? fontSize;
  final ButtonLoadingAnimationController? controller;
  final Widget? prefix, suffix;
  final Widget? child;

  const ButtonWidget({
    Key? key,
    required this.onPressed,
    required this.title,
    this.expanded = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
    this.color = MyColors.white,
    this.backgroundColor = MyColors.black,
    this.margin = const EdgeInsets.only(right: 8),
    this.loaderSize = 24,
    this.enabled = true,
    this.textDecoration,
    this.textDecorationStyle,
    this.fontSize,
    this.controller,
    this.prefix,
    this.suffix,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 24),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(32.0),
        child: getButtonWidget(),
      ),
    );
  }

  Widget getButtonWidget() {
    return ChangeNotifierProvider<ButtonLoadingAnimationController>.value(
      value: controller ?? ButtonLoadingAnimationController(),
      child: Consumer<ButtonLoadingAnimationController>(
        child: child,
        builder: (context, value, child) {
          return child != null
              ? (controller != null && value.showLoading
                  ? const Center(
                      child: SizedBox(
                        child: CircularProgressIndicator(),
                        height: 18,
                        width: 18,
                      ),
                    )
                  : child)
              : child ??
                  Container(
                    height: 40.0,
                    padding: expanded
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: enabled
                          ? backgroundColor
                          : backgroundColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(32.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(169, 176, 185, 0.42),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: controller != null && value.showLoading
                        ? Row(
                            mainAxisSize:
                                expanded ? MainAxisSize.max : MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Center(
                                child: SizedBox(
                                  child: CircularProgressIndicator(),
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize:
                                expanded ? MainAxisSize.max : MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ],
                          ),
                  );
        },
      ),
    );
  }
}
