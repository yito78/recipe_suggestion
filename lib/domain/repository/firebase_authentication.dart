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
  static Future<void> registerWithPassword(
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
  static Future<UserCredential> authenticateWithGoogle() async {
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
  static Future<void> authenticateWithPassword(
      final String emailAddress, final String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: emailAddress, password: password);
  }

  ///
  /// パスワード忘れ処理を行う
  ///
  /// [emailAddress] メールアドレス
  ///
  static Future<void> reissuePassword(final String emailAddress) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailAddress);
    } catch (e) {
      debugPrint("$e");
    }
  }

  ///
  /// サインイン済みユーザのログインIDを取得する
  ///
  /// 戻り値::サインイン済みの場合は、ユーザ情報を返却
  ///        そうでない場合、null
  ///
  static Future<String?> fetchSignedInUserId() async {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid.toString();

    // 画面開いた状態で、セッション切れた場合を想定
    // ログイン情報がなしと判断し、サインアウト処理を実行する
    // ログイン画面に戻す(状態遷移により実現)
    if (uid == null) {
      await signOut();
    }

    return uid;
  }

  ///
  /// ログアウト処理
  ///
  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("$e");
    }
  }
}
