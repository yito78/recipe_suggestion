import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
part 'login_user.g.dart';

@riverpod
// Notifierクラス
class LoginUserNotifier extends _$LoginUserNotifier {
  @override
  // 初期化処理
  User? build() {
    FirebaseAuthentication firebaseAuthentication = FirebaseAuthentication();
    return firebaseAuthentication.fetchSignedInUser();
  }
}
