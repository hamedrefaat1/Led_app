import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/screens/addpostscreen.dart';
import 'package:led/screens/addreelsscreen.dart';


class AddPostOrReelsScreen extends StatefulWidget {
  const AddPostOrReelsScreen({super.key});

  @override
  State<AddPostOrReelsScreen> createState() => _AddPostOrReelsScreenState();
}

class _AddPostOrReelsScreenState extends State<AddPostOrReelsScreen> {
  late PageController pageController;
  int _currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  onPageChanged(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
              controller: pageController,
            onPageChanged: onPageChanged,
            children: const [AddPostScreen(), Addreelsscreen()],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: 10.h,
            right: _currentIndex == 0 ? 100.w : 150.w,
            child: Container(
              width: 120.w,
              height: 30.h,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.r)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      navigationTapped(0);
                    },
                    child: Text(
                      'Post',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: _currentIndex == 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      navigationTapped(1);
                    },
                    child: Text(
                      'Reels',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: _currentIndex == 1 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
