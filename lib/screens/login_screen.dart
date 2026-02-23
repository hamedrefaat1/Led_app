import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/data/firebase_service/firebase_auth.dart';
import 'package:led/util/dialog.dart';
import 'package:led/util/exceptions.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback show;
  const LoginScreen({super.key, required this.show});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FocusNode emailF = FocusNode();
  final FocusNode passwordF = FocusNode();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    emailF.addListener(() => setState(() {}));
    passwordF.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    emailF.dispose();
    passwordF.dispose();
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
              SizedBox(height: 80.h),
              _buildLogo(),
              SizedBox(height: 10.h),
              Text(
                "Welcome back",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 60.h),
              _buildTextField(email, Icons.email_outlined, "Email", emailF),
              SizedBox(height: 12.h),
              _buildPasswordField(),
              SizedBox(height: 10.h),
              _buildForgotPassword(),
              SizedBox(height: 28.h),
              _buildLoginButton(),
              SizedBox(height: 20.h),
              _buildSignUpRedirect(),
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

  Widget _buildPasswordField() {
    final bool focused = passwordF.hasFocus;
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
        controller: password,
        focusNode: passwordF,
        obscureText: _obscurePassword,
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: "Password",
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.textHint),
          prefixIcon: Icon(
            Icons.lock_outline,
            size: 20.sp,
            color: focused ? AppColors.primary : AppColors.icon,
          ),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        "Forgot password?",
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: () async {
        try {
          await Authentication().logIn(
            email: email.text,
            password: password.text,
          );
        } on exceptions catch (e) {
          dialogBuilder(context, e.massage);
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
          "Sign In",
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

  Widget _buildSignUpRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: widget.show,
          child: Text(
            "Sign Up",
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
