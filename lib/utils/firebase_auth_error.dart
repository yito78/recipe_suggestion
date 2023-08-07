import 'package:firebase_auth/firebase_auth.dart';

/// firebase Authentication機能のエラー処理クラス
class FirebaseAuthError {
  ///
  /// エラーメッセージを返却する
  ///
  /// [error] FirebaseAuthクラスのエラー情報
  ///
  ///　戻り値::エラーメッセージ
  ///
  static String exceptionMessage(FirebaseAuthException error) {
    String message = "";

    switch (error.code) {
      case "invalid-email":
        message = "メールアドレスが間違ってます。";
        break;

      case "wrong-password":
        message = "パスワードが間違ってます。";
        break;

      case "user-not-found":
        message = "このアカウントは存在しません。";
        break;

      case "user-disabled":
        message = "このアカウントは無効です。";
        break;

      case "too-many-requests":
        message = "回線が混雑してます。時間をおいて試してください。";
        break;

      case "email-already-in-use":
        message = "このメールアドレスは既に登録されてます。";
        break;

      default:
        message = "予期せぬエラーが発生しました。システム管理者へ連絡してください。";
        break;
    }

    return message;
  }
}
