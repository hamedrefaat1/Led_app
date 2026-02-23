import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:led/data/models/usermodel.dart';
import 'package:led/util/exceptions.dart';

import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<bool> creatUser({
    required String email,
    required String userName,
    required String bio,
    required String imgProfile,
  }) async {
    await _firebaseFirestore
        .collection("users")
        .doc(_auth.currentUser!.uid)
        .set({
      "email": email,
      "userName": userName,
      "bio": bio,
      "imgProfile": imgProfile,
      "followers": [],
      "following": [],
    });
    return true;
  }

  Future<Usermodel> getUser(String uid) async {
    try {
      final user = await _firebaseFirestore
          .collection("users")
          .doc(uid)
          .get();
      final snapUser = user.data()!;
      return Usermodel( user.id,snapUser["email"], snapUser["userName"], snapUser["bio"],
          snapUser["imgProfile"], snapUser["followers"], snapUser["following"]);

    } on FirebaseException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<bool> creatPost(
    {
      required String postImage,
      required String caption,
      required String location,
    }
  )async{
      var uid= Uuid().v4();
      DateTime date= new DateTime.now();
      Usermodel user= await getUser(_auth.currentUser!.uid);
      await _firebaseFirestore.collection("posts").doc(uid).set({
         "postImage": postImage,
         "userName":user.userName,
         "userImgProfile": user.imgProfile,
         "caption":caption,
         "location":location,
         "uid":_auth.currentUser!.uid,
         "postId":uid,
         "likes":[],
         "time":date,
      });
      return true;
  }
    Future<bool> creatReels({
    required String video,
    required String caption,
  }) async {
    var uid = Uuid().v4();
    DateTime data = new DateTime.now();
    Usermodel user = await getUser(_auth.currentUser!.uid);
    await _firebaseFirestore.collection('reels').doc(uid).set({
      'reelsvideo': video,
      'username': user.userName,
      "userImgProfile": user.imgProfile,
      'caption': caption,
      'uid': _auth.currentUser!.uid,
      'postId': uid,
      'like': [],
      'time': data
    });
    return true;
  }

      Future<bool> addComment({
    required String comment,
    required String type,
    required String uidd,
  }) async {
    var uid = Uuid().v4();
    Usermodel user = await getUser(_auth.currentUser!.uid);
    await _firebaseFirestore.collection(type).doc(uidd).collection("comments").doc(uid).set({
      'comment': comment,
      'username': user.userName,
      "userImgProfile": user.imgProfile,
      'commentID': uid,
    });
    return true;
  }

  addORdeleteLike({required snapshot , required String type}) async
    {
                        String userId = FirebaseAuth.instance.currentUser!.uid;
                        String postId = snapshot["postId"]; // ID الخاص بالمنشور
                        DocumentReference postRef = FirebaseFirestore.instance
                            .collection(type)
                            .doc(postId);

                        if (snapshot[type=="posts"? "likes" : "like"].contains(userId)) {
                          await postRef.update({
                            type=="posts"? "likes" : "like": FieldValue.arrayRemove([userId])
                          });
                        } else {
                          await postRef.update({
                            type=="posts"? "likes" : "like": FieldValue.arrayUnion([userId])
                          });
                        }
                      }



  Future<void> followUser(String targetUid) async {
    String currentUid = _auth.currentUser!.uid;
    await _firebaseFirestore.collection('users').doc(targetUid).update({
      'followers': FieldValue.arrayUnion([currentUid])
    });

    await _firebaseFirestore.collection('users').doc(currentUid).update({
      'following': FieldValue.arrayUnion([targetUid])
    });
  }

  Future<void> unfollowUser(String targetUid) async {
    String currentUid = _auth.currentUser!.uid;
    await _firebaseFirestore.collection('users').doc(targetUid).update({
      'followers': FieldValue.arrayRemove([currentUid])
    });

    await _firebaseFirestore.collection('users').doc(currentUid).update({
      'following': FieldValue.arrayRemove([targetUid])
    });
  }
  
}
