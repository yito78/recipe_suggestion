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
            const SizedBox(
              height: 30.0,
            ),
            _textBox("メールアドレス"),
            const SizedBox(
              height: 10.0,
            ),
            _textBox("パスワード"),
            const SizedBox(
              height: 10.0,
            ),

            /// ログイン
            _loginButton(),

            const SizedBox(
              height: 10.0,
            ),

            /// パスワードを忘れた方
            _linkForgetPassword(),

            const SizedBox(
              height: 10.0,
            ),

            /// 新規登録
            _registerButton(),
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
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          decoration: InputDecoration(
            labelText: "$titleを入力してください",
          ),
        ));
  }

  ///
  /// ログインボタンを作成する
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _loginButton() {
    return ElevatedButton(
      onPressed: () {
        print("login buttonクリック");

        /// セッションが存在するかチェックし、存在する場合は機能一覧画面に遷移する
        /// firebaseにログイン認証を行う
        ///   ログイン成功の場合、機能一覧画面に遷移する
        ///   ログイン失敗の場合、失敗フラッシュメッセージを表示する
      },
      // style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.orange),),
      child: const Text("ログイン"),
    );
  }

  Widget _linkForgetPassword() {
    return InkWell(
      onTap: () {
        print("aaa");
      },
      child: const Text(
        "パスワードを忘れた方",
        style: TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  ///
  /// 新規登録ボタンを作成する
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _registerButton() {
    return ElevatedButton(
      onPressed: () {
        print("register buttonクリック");

        /// セッションが存在するかチェックし、存在する場合は機能一覧画面に遷移する
        /// firebaseにログイン認証を行う
        ///   ログイン成功の場合、機能一覧画面に遷移する
        ///   ログイン失敗の場合、失敗フラッシュメッセージを表示する
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.orange),
      ),
      child: const Text("新規登録"),
    );
  }
}
