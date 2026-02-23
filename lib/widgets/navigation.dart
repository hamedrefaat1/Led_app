import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/core/app_colors.dart';
import 'package:led/screens/add_post_or_reels_screen.dart';
import 'package:led/screens/exploerscreen.dart';
import 'package:led/screens/home.dart';
import 'package:led/screens/profilescreen.dart';
import 'package:led/screens/reelsscreen.dart';


class Navigation_screen extends StatefulWidget {
  const Navigation_screen({super.key});

  @override
  State<Navigation_screen> createState() => _Navigation_screenState();
}

class _Navigation_screenState extends State<Navigation_screen> {
  late PageController pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const Exploerscreen(),
    const AddPostOrReelsScreen(),
    const Reelsscreen(),
    Profilescreen(FirebaseAuth.instance.currentUser!.uid),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.icon,
          currentIndex: _currentIndex,
          onTap: navigationTapped,
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_outlined, 0),
              activeIcon: _buildActiveNavIcon(Icons.home, 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.search, 1),
              activeIcon: _buildActiveNavIcon(Icons.search, 1),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.add_box_outlined, 2),
              activeIcon: _buildActiveNavIcon(Icons.add_box, 2),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.play_circle_outline, 3),
              activeIcon: _buildActiveNavIcon(Icons.play_circle, 3),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 4),
              activeIcon: _buildActiveNavIcon(Icons.person, 4),
              label: '',
            ),
          ],
        ),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    return Icon(icon, size: 26.sp);
  }

  Widget _buildActiveNavIcon(IconData icon, int index) {
    return Container(
      padding: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: AppColors.primaryGlow,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, size: 26.sp, color: AppColors.primary),
    );
  }
}