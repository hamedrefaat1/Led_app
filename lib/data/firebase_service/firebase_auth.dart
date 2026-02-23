// ignore_for_file: unused_field, prefer_final_fields

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:led/auth/mainpage.dart';
import 'package:led/data/firebase_service/firestore.dart';
import 'package:led/data/firebase_service/storage.dart';
import 'package:led/util/exceptions.dart';

class Authentication {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> signUp({
    required String email,
    required String userName,
    required String bio,
    required String password,
    required String passwordConfirm,
    required File imgProfile,
  }) async {
    String uRL;
    try {
      if (email.isNotEmpty &&
          userName.isNotEmpty &&
          bio.isNotEmpty &&
          password.isNotEmpty) {
        if (password == passwordConfirm) {
          await _auth.createUserWithEmailAndPassword(
              email: email.trim(), password: password.trim());
          if (imgProfile != File('')) {
            uRL = await StorageMethods()
                .uploadImageToStorage("ProfileImages", imgProfile);
          } else {
            uRL = '';
          }
          await FirestoreMethods().creatUser(
              email: email,
              userName: userName,
              bio: bio,
              imgProfile: uRL == ''
                  ? "https://firebasestorage.googleapis.com/v0/b/Led-app-808af.appspot.com/o/person.png?alt=media&token=87de3c82-45c4-42f5-9d35-9640692b26ae"
                  : uRL);
                  await _auth.signOut();
        } else {
          throw exceptions("password and confirm password should be same");
        }
      } else {
        throw exceptions("enter all a fileds");
      }
    } on FirebaseAuthException catch (e) {
      throw exceptions(e.message.toString());
    }
  }

  Future<void> logIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password.trim(),
        );
      } else {
        throw exceptions("Please enter both email and password.");
      }
    } on FirebaseAuthException catch (e) {
      throw exceptions(e.message.toString());
    }
  }
}
