// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/screens/post_screen.dart';
import 'package:led/screens/profilescreen.dart';
import 'package:led/util/cache_image.dart';

class Exploerscreen extends StatefulWidget {
  const Exploerscreen({super.key});

  @override
  State<Exploerscreen> createState() => _ExploerscreenState();
}

class _ExploerscreenState extends State<Exploerscreen> {
  final TextEditingController search = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool show = false;

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSearchBar(),
            if (!show) _buildPostsGrid(),
            if (show) _buildUsersList(),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              SizedBox(width: 10.w),
              Icon(Icons.search, color: AppColors.textHint, size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: search,
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                  onChanged: (value) {
                    setState(() {
                      show = value.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (show)
                GestureDetector(
                  onTap: () {
                    search.clear();
                    setState(() => show = false);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: Icon(Icons.close, color: AppColors.icon, size: 18.sp),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsGrid() {
    return StreamBuilder(
      stream: _firebaseFirestore.collection("posts").snapshots(),
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
              final data = snapshot.data!.docs[index].data();
              final imageUrl = data.containsKey("postImage") && data["postImage"] != null
                  ? data["postImage"]
                  : "https://example.com/default_image.png";
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostScreen(data)),
                  );
                },
                child: Container(
                  color: AppColors.surfaceCard,
                  child: CacheImage(imageUrl: imageUrl),
                ),
              );
            },
            childCount: snapshot.data!.docs.length,
          ),
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            pattern: const [
              QuiltedGridTile(2, 1),
              QuiltedGridTile(2, 2),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
              QuiltedGridTile(1, 1),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder(
      stream: _firebaseFirestore
          .collection("users")
          .where("userName", isGreaterThanOrEqualTo: search.text)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final snap = snapshot.data!.docs[index];
              final imageUrl = snap.data().containsKey("imgProfile") &&
                      snap["imgProfile"] != null
                  ? snap["imgProfile"]
                  : null;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profilescreen(snap.id),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: AppColors.storyGradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                          ),
                          child: ClipOval(
                            child: SizedBox(
                              width: 44.w,
                              height: 44.w,
                              child: imageUrl != null
                                  ? CacheImage(imageUrl: imageUrl)
                                  : Container(
                                      color: AppColors.surfaceElevated,
                                      child: Icon(
                                        Icons.person,
                                        color: AppColors.icon,
                                        size: 22.sp,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snap["userName"],
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "LED user",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.chevron_right, color: AppColors.icon, size: 20.sp),
                    ],
                  ),
                ),
              );
            },
            childCount: snapshot.data!.docs.length,
          ),
        );
      },
    );
  }
}