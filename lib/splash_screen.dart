import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location1/images.dart';
import 'package:location1/main.dart';
import 'package:location1/routes.dart';
import 'package:location1/widgets/image_widget.dart';
import 'package:platform_device_id/platform_device_id.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser != null) {
      initData();
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      });
    } else {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ImageWidget(
          imageLocation: MyImages.logo,
        ),
      ),
    );
  }

  void initData() async {
    final deviceId = await PlatformDeviceId.getDeviceId ?? '';
    final data = await FirebaseFirestore.instance
        .collection('location')
        .doc(deviceId)
        .get();
    try {
      mode = data.data()?['mode'] ?? 0;
      userName = FirebaseAuth.instance.currentUser?.displayName ?? '--';
    } catch (e) {
      print(e);
    }
    FirebaseFirestore.instance.collection('location').doc(deviceId).set({
      'id': deviceId,
      'name': userName,
      'mode': mode,
    }, SetOptions(merge: true));
  }
}
