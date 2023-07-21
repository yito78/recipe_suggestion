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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signedInUserWatch = ref.watch(userProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Suggestion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: signedInUserWatch.when(
        data: (user) =>
            // ログイン済みであれば、機能一覧画面へ遷移する
            user != null ? const FunctionListPage() : const LoginPage(),
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
