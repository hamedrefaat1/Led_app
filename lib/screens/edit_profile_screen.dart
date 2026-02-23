import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/storage.dart';
import 'package:led/util/imagepicker.dart';

class EditProfileScreen extends StatefulWidget {
  final String uid;
  final String userName;
  final String bio;
  final String imgProfile;
  const EditProfileScreen({
    required this.uid,
    required this.userName,
    required this.bio,
    required this.imgProfile,
    super.key,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final FocusNode userNameF = FocusNode();
  final FocusNode bioF = FocusNode();
  bool isLoading = false;
  File? selectImage;
  String? newProfileImage;

  @override
  void initState() {
    super.initState();
    userNameController.text = widget.userName;
    bioController.text = widget.bio;
    newProfileImage = widget.imgProfile;
    userNameF.addListener(() => setState(() {}));
    bioF.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    userNameController.dispose();
    bioController.dispose();
    userNameF.dispose();
    bioF.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    File? image = await Imagepickerr().upLoadImage("gallery");
    if (image != null) {
      setState(() => selectImage = image);
    }
  }

  void updateProfileInfo() async {
    setState(() => isLoading = true);

    if (selectImage != null) {
      newProfileImage = await StorageMethods()
          .uploadImageToStorage("ProfileImages", selectImage!);
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .update({
      "userName": userNameController.text.trim(),
      "bio": bioController.text.trim(),
      "imgProfile": newProfileImage,
    });

    QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
        .collection("posts")
        .where("uid", isEqualTo: widget.uid)
        .get();

    for (var doc in postsSnapshot.docs) {
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(doc.id)
          .update({"userImgProfile": newProfileImage});
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
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
          "Edit Profile",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          isLoading
              ? Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: Center(
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: updateProfileInfo,
                  child: Container(
                    margin: EdgeInsets.only(right: 14.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Save',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 30.h),
            _buildAvatarPicker(),
            SizedBox(height: 36.h),
            _buildTextField(
              userNameController,
              Icons.person_outline,
              "Username",
              userNameF,
            ),
            SizedBox(height: 14.h),
            _buildTextField(
              bioController,
              Icons.edit_outlined,
              "Bio",
              bioF,
              maxLines: 3,
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
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
                      width: 86.w,
                      height: 86.w,
                      child: selectImage != null
                          ? Image.file(selectImage!, fit: BoxFit.cover)
                          : Image.network(widget.imgProfile, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(
                        color: AppColors.background, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, size: 14.sp, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            "Change photo",
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    IconData icon,
    String hint,
    FocusNode focusNode, {
    int maxLines = 1,
  }) {
    final bool focused = focusNode.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: focused ? AppColors.primary : AppColors.border,
              width: focused ? 1.5 : 0.8,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(fontSize: 14.sp, color: AppColors.textHint),
              prefixIcon: Icon(
                icon,
                size: 20.sp,
                color: focused ? AppColors.primary : AppColors.icon,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }
}