import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:core';
import 'dart:developer';

import 'package:provider/provider.dart';

import 'firebaseops.dart';

class Authentication with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  static String? userUid;

  String? getUserUid() {
    return userUid;
  }

  Future logIntoAccount(String email, String password) async
  {
    log('Login called');

   await _auth.signInWithEmailAndPassword(
        email: email, password: password).then((value)
   {
     UserCredential userCredential=value;
     User? user = userCredential.user;
     userUid = user?.uid;
     log('Email login userId: $userUid');
     notifyListeners();
   }).onError((error, stackTrace)
   {
     log(error.toString());
     userUid=null;
   });


  }

  Future createAccount(String email, String password) async
  {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = userCredential.user;
      userUid = user?.uid;
      log('Email register userId: $userUid');
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        log('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        log('The account already exists for that email.');
      }
    } catch (e) {
      log(e.toString());
    }

    /*
    log('Creating account');
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password).catchError((err){log(err);}).whenComplete(()
    {
          log('Account created');

    });
    User? user = userCredential.user;
    userUid = user?.uid;
    log('Email register userId: $userUid');
    notifyListeners();

     */
  }

  Future emailLogOut(context)
  {
    userUid=null;
    Provider.of<FirebaseOperations>(context, listen: false).following=[];
    return _auth.signOut();
  }

  Future signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!
        .authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    final User? user = userCredential.user;
    userUid=user!.uid;
    //log('Google User Uid: $user');

    assert(userUid!=null);
    //userUid = user?.uid;
    log('Google User Uid: $userUid');
    notifyListeners();
  }

  Future googleSignOut()
  {
    return _googleSignIn.signOut();
  }
}