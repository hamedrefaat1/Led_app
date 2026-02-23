// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/data/firebase_service/storage.dart';


class Add_Text_For_Post extends StatefulWidget {
  final File _file;
  const Add_Text_For_Post(this._file, {super.key});

  @override
  State<Add_Text_For_Post> createState() => _Add_Text_For_PostState();
}

class _Add_Text_For_PostState extends State<Add_Text_For_Post> {
  final caption = TextEditingController();
  final location = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    caption.dispose();
    location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.icon),
        title: Text(
          'New Post',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              setState(() => isLoading = true);
              String postUrl = await StorageMethods()
                  .uploadImageToStorage('post', widget._file);
              await FirestoreMethods().creatPost(
                postImage: postUrl,
                location: location.text,
                caption: caption.text,
              );
              setState(() => isLoading = false);
              Navigator.of(context).pop();
            },
            child: Container(
              margin: EdgeInsets.only(right: 14.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Share',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _buildCaptionRow(),
                  SizedBox(height: 8.h),
                  const Divider(color: AppColors.divider, thickness: 0.5),
                  _buildLocationField(),
                  const Divider(color: AppColors.divider, thickness: 0.5),
                  SizedBox(height: 20.h),
                  _buildOptionsRow(),
                ],
              ),
            ),
    );
  }

  Widget _buildCaptionRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 70.w,
              height: 70.w,
              child: Image.file(widget._file, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: caption,
              maxLines: 4,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: location,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add location',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          _buildOptionTile(Icons.people_outline, 'Tag people'),
          const Divider(color: AppColors.divider, thickness: 0.5),
          _buildOptionTile(Icons.music_note_outlined, 'Add music'),
          const Divider(color: AppColors.divider, thickness: 0.5),
          _buildOptionTile(Icons.tune_outlined, 'Advanced settings'),
        ],
      ),
    );
  }

  Widget _buildOptionTile(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.icon),
          SizedBox(width: 12.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, size: 20.sp, color: AppColors.icon),
        ],
      ),
    );
  }
}