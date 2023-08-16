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
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);
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

  ///
  /// サインイン済みユーザのログイン情報を取得する
  ///
  /// 戻り値::サインイン済みの場合は、ユーザ情報を返却
  ///        そうでない場合、null
  ///
  User? fetchSignedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  ///
  /// ログアウト処理
  ///
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("$e");
    }
  }
}
