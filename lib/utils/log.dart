import 'package:firebase_analytics/firebase_analytics.dart';

class Log {
  //
  // アクセスログ出力
  //
  // className::ログ出力対象機能のクラス名
  //
  accessLog(className) async {
    await FirebaseAnalytics.instance.logEvent(
      name: "$className",
    );
  }

  //
  // エラーログ出力
  //
  // className::ログ出力対象機能のクラス名
  // errorClass::エラークラス
  // stackTrace::スタックトレースログ
  //
  errorLog(className, [errorClass, stackTrace]) {
    FirebaseAnalytics.instance.logEvent(
      name: "Error $className",
      parameters: {
        "error class": "$errorClass",
        "trace log": "$stackTrace",
      },
    );
  }
}
