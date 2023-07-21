import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:recipe_suggestion/provider/login_user.dart';
import 'package:recipe_suggestion/view/function_list_page.dart';
import 'package:recipe_suggestion/view/login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const scope = ProviderScope(child: MyApp());
  runApp(scope);
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedInUserWatch = ref.watch(userProvider);

    return signedInUserWatch.when(
      data: (user) => _createMaterialApp(user),
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }

  ///
  /// 初期画面生成処理
  /// ログイン状態によって、初期表示画面を振り分ける
  ///   ログイン済::機能一覧画面
  ///   未ログイン::ログイン画面
  ///
  /// [user] ログインユーザ情報
  ///
  /// 戻り値::各画面Widget
  ///
  Widget _createMaterialApp(User? user) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Suggestion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // ログイン済みであれば、機能一覧画面へ遷移する
      home: user != null ? const FunctionListPage() : const LoginPage(),
    );
  }
}
