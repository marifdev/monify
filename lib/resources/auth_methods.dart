import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //signup user
  Future<String> signUpUser(String email, String password) async {
    String res = 'failed';
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      //create user document
      await _firestore.collection('users').doc(user!.uid).set({
        'email': email,
        'uid': user.uid,
        'currency': {
          'symbol': '\$',
          'code': 'USD',
        },
        'platform': Platform.isAndroid ? 'android' : 'ios',
      });
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        res = 'The email is invalid.';
      }
    } catch (e) {
      print(e.toString());
    }
    return res;
  }

  //login user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'failed';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email is invalid.';
      }
    } catch (e) {
      print(e.toString());
    }
    return res;
  }

  //delete user
  Future<void> deleteUser() async {
    try {
      User? user = _auth.currentUser;
      await user!.delete();
    } catch (e) {
      print(e.toString());
    }
  }
}
