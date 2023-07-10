import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authに関するデータ操作するクラス
class FirebaseAuthentication {
  ///
  /// メールアドレス、パスワードをもとにユーザ登録する
  ///
  /// [emailAddress] メールアドレス
  /// [password] パスワード
  ///
  Future<void> registerWithPassword(
      final String emailAddress, final String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      debugPrint("$credential");
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        debugPrint("The password provided is too weak.");
      } else if (e.code == "email-already-in-use") {
        debugPrint("The account already exists for that email.");
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  ///
  /// Googleアカウント認証を行う
  ///
  Future<UserCredential> authenticateWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  ///
  /// パスワード認証を行う
  ///
  /// [emailAddress] メールアドレス
  /// [password] パスワード
  ///
  Future<void> authenticateWithPassword(
      final String emailAddress, final String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  ///
  /// パスワード忘れ処理を行う
  ///
  /// [emailAddress] メールアドレス
  ///
  Future<void> reissuePassword(final String emailAddress) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);
    } catch (e) {
      debugPrint("$e");
    }
  }
}
