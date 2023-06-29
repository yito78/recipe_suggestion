import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/view/function_list_page.dart';

/// ログイン画面
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
              height: 20.0,
            ),

            // ログイン
            _loginButton(context, const FunctionListPage()),

            const SizedBox(
              height: 10.0,
            ),

            // パスワードを忘れた方
            _linkForgetPassword(),

            const SizedBox(
              height: 30.0,
            ),

            // Googleアカウントでログイン
            _googleLoginButton(context, const FunctionListPage()),

            const SizedBox(
              height: 20.0,
            ),

            // 新規登録
            _registerButton(context, const FunctionListPage()),
          ],
        ),
      ),
    );
  }

  ///
  /// テキスト入力エリアを作成する
  ///
  /// [title] プレースホルダーに表示するテキスト情報
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
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _loginButton(BuildContext context, page) {
    return ElevatedButton(
      onPressed: () {
        debugPrint("login buttonクリック");

        _navigate(context, page);

        // セッションが存在するかチェックし、存在する場合は機能一覧画面に遷移する
        // firebaseにログイン認証を行う
        //   ログイン成功の場合、機能一覧画面に遷移する
        //   ログイン失敗の場合、失敗フラッシュメッセージを表示する
      },
      child: const Text("ログイン"),
    );
  }

  ///
  /// ログインボタンを作成する
  ///
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _googleLoginButton(BuildContext context, Widget page) {
    return ElevatedButton(
      onPressed: () {
        debugPrint("Google login buttonクリック");

        _navigate(context, page);

        // セッションが存在するかチェックし、存在する場合は機能一覧画面に遷移する
        // firebaseにログイン認証を行う
        //   ログイン成功の場合、機能一覧画面に遷移する
        //   ログイン失敗の場合、失敗フラッシュメッセージを表示する
      },
      child: const Text("Googleアカウントログイン"),
    );
  }

  ///
  /// パスワード忘れリンクウィジェットを作成する
  ///
  /// 戻り値::パスワード忘れリンクウィジェット
  ///
  Widget _linkForgetPassword() {
    return InkWell(
      onTap: () {
        debugPrint("aaa");
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
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _registerButton(BuildContext context, Widget page) {
    return ElevatedButton(
      onPressed: () {
        debugPrint("register buttonクリック");

        _navigate(context, page);

        // セッションが存在するかチェックし、存在する場合は機能一覧画面に遷移する
        // firebaseにログイン認証を行う
        //   ログイン成功の場合、機能一覧画面に遷移する
        //   ログイン失敗の場合、失敗フラッシュメッセージを表示する
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(Colors.orange),
      ),
      child: const Text("新規登録"),
    );
  }

  ///
  /// 画面遷移処理
  ///
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  ///
  /// 戻り値::なし
  ///
  _navigate(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
