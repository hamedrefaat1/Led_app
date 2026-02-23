import 'package:flutter/material.dart';
import 'package:led/widgets/post_widget.dart';


class PostScreen extends StatelessWidget {
  final snapshot;
  const PostScreen(this.snapshot);

  @override
  Widget build(BuildContext context) {
       return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: PostWidget(snapshot)),
    );
  }
}