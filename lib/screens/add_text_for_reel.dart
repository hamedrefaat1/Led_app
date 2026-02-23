// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/data/firebase_service/storage.dart';

import 'package:video_player/video_player.dart';

class ReelsEditeScreen extends StatefulWidget {
  final File videoFile;
  const ReelsEditeScreen(this.videoFile, {super.key});

  @override
  State<ReelsEditeScreen> createState() => _ReelsEditeScreenState();
}

class _ReelsEditeScreenState extends State<ReelsEditeScreen> {
  final caption = TextEditingController();
  late VideoPlayerController controller;
  bool isLoading = false;
  bool isVideoInitialized = false;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => isVideoInitialized = true);
        }
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    caption.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      isPlaying ? controller.play() : controller.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.icon),
        title: Text(
          'New Reel',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  _buildVideoPreview(),
                  SizedBox(height: 20.h),
                  _buildCaptionField(),
                  Divider(color: AppColors.divider, thickness: 0.5),
                  SizedBox(height: 24.h),
                  _buildButtons(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
    );
  }

  Widget _buildVideoPreview() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          width: 220.w,
          height: 380.h,
          child: isVideoInitialized
              ? GestureDetector(
                  onTap: _togglePlay,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                      AnimatedOpacity(
                        opacity: isPlaying ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black45,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  color: AppColors.surfaceCard,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_outlined, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: caption,
              maxLines: 3,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Save draft',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                setState(() => isLoading = true);
                String reelsUrl = await StorageMethods()
                    .uploadImageToStorage('Reels', widget.videoFile);
                await FirestoreMethods().creatReels(
                  video: reelsUrl,
                  caption: caption.text,
                );
                setState(() => isLoading = false);
                Navigator.of(context).pop();
              },
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}