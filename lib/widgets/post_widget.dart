import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/util/cache_image.dart';
import 'package:led/widgets/comment_widget.dart';
import 'package:led/widgets/like_animation.dart';


class PostWidget extends StatefulWidget {
  final snapshot;
  PostWidget(this.snapshot);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  bool isLikeAnimating = false;

  @override
  Widget build(BuildContext context) {
    final bool isLiked = widget.snapshot["likes"]
        .contains(FirebaseAuth.instance.currentUser!.uid);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildImage(),
          _buildActions(isLiked),
          _buildInfo(),
          Divider(color: AppColors.divider, thickness: 0.5, height: 0),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
                  width: 36.w,
                  height: 36.w,
                  child: CacheImage(imageUrl: widget.snapshot["userImgProfile"]),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.snapshot["userName"],
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                if (widget.snapshot["location"] != null &&
                    widget.snapshot["location"].toString().isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 10.sp, color: AppColors.primary),
                      SizedBox(width: 2.w),
                      Text(
                        widget.snapshot["location"],
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Icon(Icons.more_horiz, color: AppColors.icon, size: 22.sp),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onDoubleTap: () async {
        await doLikeWhenDoubleClick();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: 340.h,
            child: CacheImage(imageUrl: widget.snapshot["postImage"]),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isLikeAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isLikeAnimating,
              duration: const Duration(milliseconds: 400),
              onEnd: () {
                setState(() {
                  isLikeAnimating = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.likeGlow,
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: AppColors.like,
                  size: 100.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isLiked) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          _buildActionButton(
            onTap: () async {
              await FirestoreMethods()
                  .addORdeleteLike(snapshot: widget.snapshot, type: 'posts');
            },
            icon: isLiked ? Icons.favorite : Icons.favorite_outline,
            color: isLiked ? AppColors.like : AppColors.icon,
            glowColor: isLiked ? AppColors.likeGlow : Colors.transparent,
          ),
          SizedBox(width: 6.w),
          Text(
            "${widget.snapshot["likes"].length}",
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 18.w),
          _buildActionButton(
            onTap: () {
              showBottomSheet(
                backgroundColor: Colors.transparent,
                context: context,
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: DraggableScrollableSheet(
                      maxChildSize: 0.6.h,
                      initialChildSize: 0.6.h,
                      minChildSize: 0.2.h,
                      builder: (context, scrollController) {
                        return CommentWidget("posts", widget.snapshot["postId"]);
                      },
                    ),
                  );
                },
              );
            },
            icon: Icons.chat_bubble_outline_rounded,
            color: AppColors.icon,
          ),
          SizedBox(width: 18.w),
          _buildActionButton(
            onTap: () {},
            icon: Icons.send_outlined,
            color: AppColors.icon,
          ),
          const Spacer(),
          _buildActionButton(
            onTap: () {},
            icon: Icons.bookmark_border_rounded,
            color: AppColors.icon,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    Color glowColor = Colors.transparent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: glowColor != Colors.transparent
              ? [BoxShadow(color: glowColor, blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Icon(icon, size: 24.sp, color: color),
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: EdgeInsets.only(left: 14.w, right: 14.w, bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${widget.snapshot["userName"]} ",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: widget.snapshot["caption"],
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            formatDate(widget.snapshot["time"].toDate(), [yyyy, '-', mm, '-', dd]),
            style: TextStyle(fontSize: 11.sp, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  doLikeWhenDoubleClick() async {
    setState(() {
      isLikeAnimating = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String postId = widget.snapshot["postId"];
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("posts").doc(postId);
    await postRef.update({
      "likes": FieldValue.arrayUnion([userId])
    });
  }
}