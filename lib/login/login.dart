import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location1/colors.dart';
import 'package:location1/images.dart';
import 'package:location1/login/controller/login_controller.dart';
import 'package:location1/sized_box.dart';
import 'package:location1/widgets/button_widget.dart';
import 'package:location1/widgets/image_widget.dart';
import 'package:location1/widgets/label_widget.dart';
import 'package:location1/widgets/loading_animation_controller.dart';
import 'package:location1/widgets/textfield_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    Get.put(controller);
    super.initState();
  }

  final controller = LoginController();
  final loginButtonController = ButtonLoadingAnimationController();
  final signupButtonController = ButtonLoadingAnimationController();

  String? emailValidator(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value ?? '')) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String? pwdValidator(String? value) {
    if ((value ?? '').length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  Widget buildTabs() {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => controller.tabController!.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const LabelWidget(
                      'Login',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: controller.pageIndex.value == 0
                            ? MyColors.textColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: Get.size.width * 0.3,
                      height: 5,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => controller.tabController!.animateTo(
                1,
                duration: const Duration(milliseconds: 500),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const LabelWidget(
                      'Signup',
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: controller.pageIndex.value == 1
                            ? MyColors.textColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: Get.size.width * 0.3,
                      height: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget buildLoginFlow() {
    return ListView(
      reverse: true,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              buildTabs(),
              CustomSizedBox.h24,
              TextFieldWidget(
                hintText: 'Email',
                suffixIcon: Icons.mail_outline_rounded,
                onChanged: (val) {
                  if (val.contains(' ')) {
                    if (mounted) {
                      setState(() {
                        controller.email.value = val.trim();
                      });
                    }
                  } else {
                    controller.email.value = val.trim();
                  }
                },
                initialValue: controller.email.value,
                validator: emailValidator,
              ),
              TextFieldWidget(
                hintText: 'Password',
                onChanged: (val) {
                  controller.password.value = val;
                },
                initialValue: controller.password.value,
                suffixIcon: Icons.password,
                validator: pwdValidator,
              ),
              CustomSizedBox.h59,
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ButtonWidget(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      loginButtonController.startLoadingAnimation();
                      await controller.login(context);
                      loginButtonController.stopLoadingAnimation();
                    }
                  },
                  title: 'Login',
                  controller: loginButtonController,
                ),
              ),
            ],
          ),
        ),
        CustomSizedBox.h40,
        ImageWidget(imageLocation: MyImages.logo),
      ],
    );
  }

  Widget buildRegisterFlow() {
    return ListView(
      reverse: true,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              buildTabs(),
              CustomSizedBox.h24,
              TextFieldWidget(
                hintText: 'Email',
                suffixIcon: Icons.mail_outline_rounded,
                onChanged: (val) {
                  controller.email.value = val;
                },
                initialValue: controller.email.value,
                validator: emailValidator,
              ),
              TextFieldWidget(
                hintText: 'Password',
                suffixIcon: Icons.password,
                onChanged: (val) {
                  controller.password.value = val;
                },
                initialValue: controller.password.value,
                validator: pwdValidator,
              ),
              // TextFieldWidget(
              //   hintText: 'Nest Code',
              //   suffixIcon: Icons.security,
              //   onChanged: (val) {
              //     controller.nestCode.value = val;
              //   },
              //   initialValue: controller.nestCode.value,
              //   maxLength: 6,
              //   textInputType: TextInputType.number,
              //   validator: (String? value) {
              //     if (value!.isEmpty || value.length < 6) {
              //       return 'Please enter 6 digit nest code.';
              //     } else {
              //       return null;
              //     }
              //   },
              // ),
              CustomSizedBox.h12,
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ButtonWidget(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (_formKey.currentState!.validate()) {
                      signupButtonController.startLoadingAnimation();
                      controller.register(context);
                      signupButtonController.stopLoadingAnimation();
                    }
                  },
                  title: 'Signup',
                  controller: signupButtonController,
                ),
              ),
            ],
          ),
        ),
        CustomSizedBox.h40,
        ImageWidget(imageLocation: MyImages.logo),
      ],
    );
  }

  Widget buildScreen() {
    // return RotatedBox(
    //   quarterTurns: 1,
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       CustomSizedBox.h30,
    //       Center(
    //         child: AnimatedTextKit(
    //           animatedTexts: [
    //             TyperAnimatedText(
    //               'WWW.NIXBEES.COM',
    //               textStyle: const TextStyle(
    //                 fontSize: 30,
    //                 color: MyColors.black,
    //                 fontWeight: FontWeight.bold,
    //                 decoration: TextDecoration.underline,
    //               ),
    //               speed: Duration(
    //                 seconds: 'WWW.NIXBEES.COM'.toString().length ~/ 13,
    //               ),
    //             ),
    //           ],
    //           totalRepeatCount: 1,
    //           displayFullTextOnTap: true,
    //         ),
    //       ),
    //       Expanded(
    //         child: Lottie.network(
    //           'https://assets4.lottiefiles.com/packages/lf20_i22x4uu7.json',
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return TabBarView(
      controller: controller.getTabController(this),
      children: [
        buildLoginFlow(),
        buildRegisterFlow(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: buildScreen(),
        ),
      ),
    );
  }
}
