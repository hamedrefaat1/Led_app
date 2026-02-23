// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/util/cache_image.dart';
import 'package:led/widgets/comment_widget.dart';
import 'package:led/widgets/like_animation.dart';
import 'package:video_player/video_player.dart';

class ReelWidget extends StatefulWidget {
  final snapshot;
  const ReelWidget(this.snapshot, {super.key});

  @override
  State<ReelWidget> createState() => _ReelWidgetState();
}

class _ReelWidgetState extends State<ReelWidget> {
  late VideoPlayerController controller;
  bool play = true;
  bool isLikeAnimating = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.snapshot["reelsvideo"]))
      ..initialize().then((onValue) {
        setState(() {
          controller.setLooping(true);
          controller.setVolume(1);
          controller.play();
        });
      });
  }

  @override
  void dispose() {
    controller.pause();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onDoubleTap: () async {
            await doLikeWhenDoubleClick();
          },
          onTap: () {
            setState(() {
              play = !play;
            });
            if (play) {
              controller.play();
            } else {
              controller.pause();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 812.h,
                child: VideoPlayer(controller),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLikeAnimating ? 1 : 0,
                child: LikeAnimation(
                  isAnimating: isLikeAnimating,
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  },
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 111,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!play)
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  play = !play;
                  controller.play();
                });
              },
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 25.r,
                child: Icon(
                  Icons.play_arrow,
                  size: 35.w,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Positioned(
          top: 430.h,
          right: 14.w,
          child: Column(
            children: [
              GestureDetector(
                  onTap: () async {
                    await FirestoreMethods().addORdeleteLike(
                        snapshot: widget.snapshot, type: 'reels');
                  },
                  child: widget.snapshot["like"]
                          .contains(FirebaseAuth.instance.currentUser!.uid)
                      ? Icon(
                          Icons.favorite,
                          size: 25.w,
                          color: Colors.red,
                        )
                      : Icon(Icons.favorite_outline,
                          size: 25.w, color: Colors.white)),
              SizedBox(
                height: 3.h,
              ),
              Text(widget.snapshot["like"].length.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp)),
              SizedBox(
                height: 15.h,
              ),
              GestureDetector(
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
                                //***********************************************// */
                                return CommentWidget(
                                    "reels", widget.snapshot["postId"]);
                              }),
                        );
                      });
                },
                child: Icon(
                  Icons.comment,
                  color: Colors.white,
                  size: 28.w,
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              FutureBuilder<int>(
                future:
                    getCommentCount(), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("...",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp)); 
                  }
                  if (snapshot.hasError) {
                    return Text("Error",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp)); 
                  }
                  return Text(snapshot.data.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp)); 
                },
              ),
              SizedBox(
                height: 15.h,
              ),
              Icon(
                Icons.send,
                color: Colors.white,
                size: 28.w,
              ),
              SizedBox(
                height: 3.h,
              ),
              Text("0", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            ],
          ),
        ),
        Positioned(
          bottom: 40.h,
          left: 10.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: SizedBox(
                      height: 35.h,
                      width: 35.w,
                      child: CacheImage(
                          imageUrl: widget.snapshot["userImgProfile"]),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(widget.snapshot["username"],
                      style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 10.w,
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 25.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text("Follow",
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(widget.snapshot["caption"],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                  )),
            ],
          ),
        )
      ],
    );
  }

  doLikeWhenDoubleClick() async {
    setState(() {
     isLikeAnimating = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String postId = widget.snapshot["postId"]; // ID الخاص بالمنشور
    DocumentReference postRef =
        FirebaseFirestore.instance.collection("reels").doc(postId);
    await postRef.update({
      "reels" == "posts" ? "likes" : "like": FieldValue.arrayUnion([userId])
    });
  }

  Future<int> getCommentCount() async {
    QuerySnapshot snapshot = await _firestore
        .collection("reels")
        .doc(widget.snapshot["postId"])
        .collection("comments")
        .get();

    return snapshot.docs.length;
  }
}
