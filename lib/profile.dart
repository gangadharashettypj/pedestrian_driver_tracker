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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomSizedBox.h40,
          Center(
            child: ImageWidget(
              imageLocation: MyImages.profile,
              height: 200,
            ),
          ),
          CustomSizedBox.h18,
          Center(
            child: LabelWidget(
              FirebaseAuth.instance.currentUser?.displayName ?? 'User',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.textDarkColor,
            ),
          ),
          CustomSizedBox.h4,
          const Center(
            child: LabelWidget(
              'Username',
              fontSize: 12,
              color: Colors.deepOrange,
            ),
          ),
          CustomSizedBox.h18,
          Center(
            child: LabelWidget(
              FirebaseAuth.instance.currentUser?.email ?? '--',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.textDarkColor,
            ),
          ),
          CustomSizedBox.h4,
          const Center(
            child: LabelWidget(
              'email',
              fontSize: 12,
              color: Colors.deepOrange,
            ),
          ),
          CustomSizedBox.h18,
          Center(
            child: LabelWidget(
              FirebaseAuth.instance.currentUser?.photoURL ?? '--',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: MyColors.textDarkColor,
            ),
          ),
          CustomSizedBox.h4,
          const Center(
            child: LabelWidget(
              'Emergency Email ID',
              fontSize: 12,
              color: Colors.deepOrange,
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
    );
  }
}
