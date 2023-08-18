import 'package:firebase_auth/firebase_auth.dart';

///
/// エラーメッセージを返却する
///
/// [error] FirebaseAuthクラスのエラー情報
///
///　戻り値::エラーメッセージ
///
String getExceptionMessage(FirebaseAuthException error) {
  // String return "";

  switch (error.code) {
    case "invalid-email":
      return "メールアドレスが間違ってます。";

    case "wrong-password":
      return "パスワードが間違ってます。";

    case "user-not-found":
      return "このアカウントは存在しません。";

    case "user-disabled":
      return "このアカウントは無効です。";

    case "too-many-requests":
      return "回線が混雑してます。時間をおいて試してください。";

    case "email-already-in-use":
      return "このメールアドレスは既に登録されてます。";

    default:
      return "予期せぬエラーが発生しました。システム管理者へ連絡してください。";
  }
}
