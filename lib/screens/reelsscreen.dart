import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:led/widgets/reel_widget.dart';


class Reelsscreen extends StatefulWidget {
  const Reelsscreen({super.key});

  @override
  State<Reelsscreen> createState() => _ReelsscreenState();
}

class _ReelsscreenState extends State<Reelsscreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder(
          stream: _firebaseFirestore.collection("reels").orderBy("time",descending: true).snapshots(),
           builder: (context, snapshot){
               return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: PageController(initialPage: 0, viewportFraction: 1),
                itemBuilder: (context,index){
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator());
                  }
                  return ReelWidget(snapshot.data!.docs[index].data());
                },
                itemCount: snapshot.data ==null? 0: snapshot.data!.docs.length,
                );
           }
           )
        ),

    );
  }
}