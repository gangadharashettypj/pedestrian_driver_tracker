import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location1/extensions/get_extensions.dart';
import 'package:location1/routes.dart';

class AuthUtils extends GetxController {
  var user = FirebaseAuth.instance.currentUser.obs;

  AuthUtils() {
    FirebaseAuth.instance.userChanges().listen((event) {
      if (event == null) {
        return;
      }

      user.value = event;
    });
  }

  Future<UserCredential?> login(String email, String pwd) async {
    try {
      final response = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pwd,
      );

      if (response.user != null) {}
      return response;
    } catch (e, st) {
      print(e);
      print(st);
      if (e.toString().contains('user-not-found')) {
        toast("User wit email $email doesn't exist, try again...");
      } else if (e.toString().contains('wrong-password')) {
        toast("Invalid user name or password, try again...");
      } else {
        toast("Something went wrong, try again...");
      }
      return null;
    }
  }

  Future<void> signOut(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser != null) {}

    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, AppRoutes.splash);
  }
}
