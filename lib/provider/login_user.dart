import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

final currentUser = Provider<User>((ref) => throw UnimplementedError());

final userProvider = StreamProvider<User?>((ref) async* {
  final auth = FirebaseAuth.instance;
  final userStream = auth.authStateChanges();
  await for (final user in userStream) {
    yield user;
  }
});
