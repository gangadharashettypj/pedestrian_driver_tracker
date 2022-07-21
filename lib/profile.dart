import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location1/colors.dart';
import 'package:location1/images.dart';
import 'package:location1/routes.dart';
import 'package:location1/sized_box.dart';
import 'package:location1/widgets/button_widget.dart';
import 'package:location1/widgets/image_widget.dart';
import 'package:location1/widgets/label_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.blue,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            top: 200,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: Color(0xD9E5E5E5),
              ),
            ),
          ),
          Positioned.fill(
            top: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ImageWidget(
                    imageLocation: MyImages.profile,
                    height: 200,
                  ),
                ),
                CustomSizedBox.h18,
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const LabelWidget(
                    'Username',
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CustomSizedBox.h4,
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: LabelWidget(
                        FirebaseAuth.instance.currentUser?.displayName ??
                            'User',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textDarkColor,
                      ),
                    ),
                  ),
                ),
                CustomSizedBox.h18,
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const LabelWidget(
                    'email',
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: LabelWidget(
                        FirebaseAuth.instance.currentUser?.email ?? '--',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textDarkColor,
                      ),
                    ),
                  ),
                ),
                CustomSizedBox.h18,
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: const LabelWidget(
                    'Emergency Email ID',
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: LabelWidget(
                        FirebaseAuth.instance.currentUser?.photoURL ?? '--',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: MyColors.textDarkColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 64),
                  child: ButtonWidget(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(context, AppRoutes.splash);
                    },
                    title: 'SIGN OUT',
                  ),
                ),
                CustomSizedBox.h30,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
