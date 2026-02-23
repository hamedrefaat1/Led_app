// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/data/models/usermodel.dart';
import 'package:led/screens/edit_profile_screen.dart';
import 'package:led/screens/post_screen.dart';
import 'package:led/util/cache_image.dart';


class Profilescreen extends StatefulWidget {
  final uid;
  const Profilescreen(this.uid, {super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  int _postCount = 0;

  @override
  void initState() {
    super.initState();
    _getPostCount();
  }

  void _getPostCount() async {
    QuerySnapshot postSnap = await _firebaseFirestore
        .collection("posts")
        .where("uid", isEqualTo: widget.uid)
        .get();
    setState(() {
      _postCount = postSnap.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder(
                  future: FirestoreMethods().getUser(widget.uid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    return _buildHeader(snapshot.data!);
                  },
                ),
              ),
              StreamBuilder(
                stream: _firebaseFirestore
                    .collection("posts")
                    .where("uid", isEqualTo: widget.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    );
                  }
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var snap = snapshot.data!.docs[index].data();
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PostScreen(snap),
                            ));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: CacheImage(imageUrl: snap["postImage"]),
                          ),
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 1,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Usermodel user) {
    bool isMyProfile = user.uid == FirebaseAuth.instance.currentUser!.uid;
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          _buildAvatarAndStats(user),
          SizedBox(height: 14.h),
          _buildUserInfo(user),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: isMyProfile
                ? _buildEditButtonAndLogoutButton(user)
                : _buildFollowMessageButtons(user),
          ),
          SizedBox(height: 14.h),
          _buildTabBar(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildAvatarAndStats(Usermodel user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: AppColors.storyGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2.5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 76.w,
                  height: 76.w,
                  child: CacheImage(imageUrl: user.imgProfile),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem("$_postCount", "Posts"),
                _buildStatItem("${user.followers.length}", "Followers"),
                _buildStatItem("${user.following.length}", "Following"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(Usermodel user) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.userName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (user.bio.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              user.bio,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
Widget _buildEditButtonAndLogoutButton(Usermodel user) {
  return Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  uid: _auth.currentUser!.uid,
                  userName: user.userName,
                  bio: user.bio,
                  imgProfile: user.imgProfile,
                ),
              ),
            );
          },
          child: Container(
            alignment: Alignment.center,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
      SizedBox(width: 8.w),
      GestureDetector(
        onTap: () async {
          await FirebaseAuth.instance.signOut();
        },
        child: Container(
          height: 36.h,
          width: 36.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            Icons.logout,
            size: 18.sp,
            color: AppColors.like,
          ),
        ),
      ),
    ],
  );
}
  Widget _buildFollowMessageButtons(Usermodel user) {
    bool isFollowing =
        user.followers.contains(FirebaseAuth.instance.currentUser!.uid);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              if (isFollowing) {
                await FirestoreMethods().unfollowUser(user.uid);
              } else {
                await FirestoreMethods().followUser(user.uid);
              }
              setState(() {});
            },
            child: Container(
              height: 36.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isFollowing
                    ? null
                    : LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                color: isFollowing ? AppColors.surfaceElevated : null,
                borderRadius: BorderRadius.circular(8.r),
                border: isFollowing
                    ? Border.all(color: AppColors.border)
                    : null,
              ),
              child: Text(
                isFollowing ? "Unfollow" : "Follow",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isFollowing ? AppColors.textPrimary : Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 36.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                "Message",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: TabBar(
        unselectedLabelColor: AppColors.icon,
        labelColor: AppColors.primary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 1.5,
        tabs: [
          Tab(icon: Icon(Icons.grid_on, size: 22.sp)),
          Tab(icon: Icon(Icons.play_circle_outline, size: 22.sp)),
          Tab(icon: Icon(Icons.person_pin_outlined, size: 22.sp)),
        ],
      ),
    );
  }
}