// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/util/cache_image.dart';


class CommentWidget extends StatefulWidget {
  final String type;
  final String uidd;
  const CommentWidget(this.type, this.uidd, {super.key});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final TextEditingController _comment = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
      ),
      child: Container(
        color: AppColors.surfaceCard,
        height: 300.h,
        child: Column(
          children: [
            _buildHandle(),
            _buildTitle(),
            Divider(color: AppColors.divider, thickness: 0.5, height: 0),
            Expanded(child: _buildCommentsList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 6.h),
      child: Container(
        height: 4.h,
        width: 40.w,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        "Comments",
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return StreamBuilder(
      stream: _firestore
          .collection(widget.type)
          .doc(widget.uidd)
          .collection("comments")
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildCommentItem(snapshot.data!.docs[index].data());
          },
        );
      },
    );
  }

  Widget _buildCommentItem(final snapshot) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: SizedBox(
              height: 34.w,
              width: 34.w,
              child: CacheImage(imageUrl: snapshot["userImgProfile"]),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(14.r),
                  bottomLeft: Radius.circular(14.r),
                  bottomRight: Radius.circular(14.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot["username"],
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    snapshot["comment"],
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: TextField(
                controller: _comment,
                maxLines: 1,
                style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              if (_comment.text.isNotEmpty) {
                FirestoreMethods().addComment(
                  comment: _comment.text,
                  type: widget.type,
                  uidd: widget.uidd,
                );
                setState(() {
                  _comment.clear();
                });
              }
            },
            child: Container(
              padding: EdgeInsets.all(9.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGlow,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}