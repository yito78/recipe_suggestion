import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recipe Suggestion"),
        ),
        body: Column(
          children: [
            const Text("メールアドレス"),
            const SizedBox(
              height: 5.0,
            ),
            _textBox("メールアドレス"),
            const SizedBox(
              height: 5.0,
            ),
            const Text("パスワード"),
            _textBox("パスワード"),
          ],
        ),
      ),
    );
  }

  ///
  /// テキスト入力エリアを作成する
  ///
  /// title::プレースホルダーに表示するテキスト情報
  ///
  /// 戻り値::TextFormFieldウィジェット
  ///
  Widget _textBox(String title) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "$titleを入力してください",
      ),
    );
  }
}
