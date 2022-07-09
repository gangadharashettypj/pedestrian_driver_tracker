import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:location1/auth/auth_utils.dart';
import 'package:location1/extensions/get_extensions.dart';
import 'package:location1/routes.dart';

enum AuthResultStatus {
  successful,
  emailAlreadyExists,
  wrongPassword,
  invalidEmail,
  userNotFound,
  userDisabled,
  operationNotAllowed,
  tooManyRequests,
  undefined,
}

class LoginController extends GetxController {
  TabController? tabController;
  final _authUtils = GetIt.I<AuthUtils>();

  var email = ''.obs;
  var password = ''.obs;
  var nestCode = '121212'.obs;
  var pageIndex = 0.obs;

  TabController getTabController(dynamic vsy) {
    if (tabController == null) {
      tabController = TabController(
        length: 2,
        vsync: vsy,
      );

      tabController!.addListener(() {
        pageIndex.value = tabController!.index;
      });
    }

    return tabController!;
  }

  Future<void> login(BuildContext context) async {
    final userData = await _authUtils.login(
      email.value,
      password.value,
    );
    if (userData?.user != null) {
      Navigator.pushReplacementNamed(context, AppRoutes.splash);
    }
  }

  Future<void> register(BuildContext context) async {
    showProgressDialog(context, 'Registering user');

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email.value,
      password: password.value,
    )
        .then((currentUser) async {
      final name = FirebaseAuth.instance.currentUser!.email!.split('@').first;
      await FirebaseAuth.instance.currentUser!.updateProfile(displayName: name);

      toast('User registered successfully');

      hideProgressDialog();
      Navigator.pushReplacementNamed(context, AppRoutes.splash);
    }).catchError((err) {
      print(err);
      hideProgressDialog();
      Fluttertoast.showToast(
        msg: generateExceptionMessage(handleException(err)),
      );
    });
  }

  AuthResultStatus handleException(e) {
    switch (e.code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return AuthResultStatus.emailAlreadyExists;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return AuthResultStatus.wrongPassword;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return AuthResultStatus.userNotFound;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return AuthResultStatus.userDisabled;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return AuthResultStatus.tooManyRequests;
      case "ERROR_OPERATION_NOT_ALLOWED":
        return AuthResultStatus.operationNotAllowed;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return AuthResultStatus.invalidEmail;
      default:
        return AuthResultStatus.undefined;
    }
  }

  ///
  /// Accepts AuthExceptionHandler.errorType
  ///
  String generateExceptionMessage(exceptionCode) {
    switch (exceptionCode) {
      case AuthResultStatus.invalidEmail:
        return 'Your email address appears to be malformed.';
      case AuthResultStatus.wrongPassword:
        return 'Your password is wrong.';
      case AuthResultStatus.userNotFound:
        return 'User with this email doesn\'t exist.';
      case AuthResultStatus.userDisabled:
        return 'User with this email has been disabled.';
      case AuthResultStatus.tooManyRequests:
        return 'Too many requests. Try again later.';
      case AuthResultStatus.operationNotAllowed:
        return 'Signing in with Email and Password is not enabled.';
      case AuthResultStatus.emailAlreadyExists:
        return 'The email has already been registered. Please login or reset your password.';
      default:
        return 'Something went wrong, try again later.';
    }
  }
}
