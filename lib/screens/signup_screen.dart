// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firebase_auth.dart';
import 'package:led/screens/login_screen.dart';
import 'package:led/util/dialog.dart';
import 'package:led/util/exceptions.dart';
import 'package:led/util/imagepicker.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback show;
  const SignUpScreen({super.key, required this.show});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController userName = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController passwordConfirm = TextEditingController();

  final FocusNode emailF = FocusNode();
  final FocusNode userNameF = FocusNode();
  final FocusNode bioF = FocusNode();
  final FocusNode passwordF = FocusNode();
  final FocusNode passwordConfirmF = FocusNode();

  File? _imageFile;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    for (var node in [emailF, userNameF, bioF, passwordF, passwordConfirmF]) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (var c in [email, userName, bio, password, passwordConfirm]) {
      c.dispose();
    }
    for (var n in [emailF, userNameF, bioF, passwordF, passwordConfirmF]) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 48.h),
              _buildLogo(),
              SizedBox(height: 10.h),
              Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              _buildAvatar(),
              SizedBox(height: 32.h),
              _buildTextField(email, Icons.email_outlined, "Email", emailF),
              SizedBox(height: 12.h),
              _buildTextField(
                  userName, Icons.person_outline, "Username", userNameF),
              SizedBox(height: 12.h),
              _buildTextField(bio, Icons.edit_outlined, "Bio", bioF),
              SizedBox(height: 12.h),
              _buildPasswordField(
                  password, "Password", passwordF, _obscurePassword, () {
                setState(() => _obscurePassword = !_obscurePassword);
              }),
              SizedBox(height: 12.h),
              _buildPasswordField(passwordConfirm, "Confirm Password",
                  passwordConfirmF, _obscureConfirm, () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              }),
              SizedBox(height: 24.h),
              _buildSignUpButton(),
              SizedBox(height: 20.h),
              _buildLoginRedirect(),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: AppColors.storyGradient,
      ).createShader(bounds),
      child: Text(
        'LED',
        style: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () async {
        File imageFile = await Imagepickerr().upLoadImage("gallery");
        setState(() => _imageFile = imageFile);
      },
      child: Stack(
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
                  width: 80.w,
                  height: 80.w,
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.surfaceElevated,
                          child: Icon(
                            Icons.person,
                            size: 36.sp,
                            color: AppColors.icon,
                          ),
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(Icons.add, size: 14.sp, color: Colors.white),
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
    FocusNode focusNode,
  ) {
    final bool focused = focusNode.hasFocus;
    return Container(
      height: 50.h,
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
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
          prefixIcon: Icon(
            icon,
            size: 20.sp,
            color: focused ? AppColors.primary : AppColors.icon,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    FocusNode focusNode,
    bool obscure,
    VoidCallback toggle,
  ) {
    final bool focused = focusNode.hasFocus;
    return Container(
      height: 50.h,
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
        obscureText: obscure,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
          prefixIcon: Icon(
            Icons.lock_outline,
            size: 20.sp,
            color: focused ? AppColors.primary : AppColors.icon,
          ),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18.sp,
              color: AppColors.icon,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: () async {
        try {
          await Authentication().signUp(
            email: email.text,
            userName: userName.text,
            bio: bio.text,
            password: password.text,
            passwordConfirm: passwordConfirm.text,
            imgProfile: _imageFile!,
          );
          if (mounted) widget.show();
        } on exceptions catch (e) {
          if (mounted) dialogBuilder(context, e.massage);
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGlow,
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          "Sign Up",
          style: TextStyle(
            fontSize: 15.sp,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: widget.show,
          child: Text(
            "Sign In",
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
