// ignore_for_file: prefer_const_constructors, unused_field

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/widgets/post_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: AppColors.storyGradient,
          ).createShader(bounds),
          child: Text(
            'LED',
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.camera_alt_outlined, color: AppColors.icon),
          onPressed: () {},
        ),
        actions: [
          Icon(Icons.favorite_border_outlined, color: AppColors.icon),
          SizedBox(width: 16.w),
          Icon(Icons.send_outlined, color: AppColors.icon),
          SizedBox(width: 13.w),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          StreamBuilder(
            stream: _firebaseFirestore
                .collection("posts")
                .orderBy("time", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    return PostWidget(snapshot.data!.docs[index].data());
                  },
                  childCount: snapshot.data == null ? 0 : snapshot.data!.docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}