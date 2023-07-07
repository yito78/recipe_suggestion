import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/view/forget_password_page.dart';
import 'package:recipe_suggestion/view/function_list_page.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';

/// ログイン画面
class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailTextEditController =
        TextEditingController();
    final TextEditingController passwordTextEditController =
        TextEditingController();

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
            _textBox("メールアドレス", emailTextEditController),
            const SizedBox(
              height: 10.0,
            ),
            _textBox("パスワード", passwordTextEditController),
            const SizedBox(
              height: 20.0,
            ),

            // ログイン
            _loginButton(context, const FunctionListPage(),
                emailTextEditController, passwordTextEditController),

            const SizedBox(
              height: 10.0,
            ),

            // パスワードを忘れた方
            _linkForgetPassword(context, const ForgetPasswordPage()),

            const SizedBox(
              height: 30.0,
            ),

            // Googleアカウントでログイン
            _googleLoginButton(context, const FunctionListPage()),

            const SizedBox(
              height: 20.0,
            ),

            // 新規登録
            _registerButton(context, const FunctionListPage(),
                emailTextEditController, passwordTextEditController),
          ],
        ),
      ),
    );
  }

  ///
  /// テキスト入力エリアを作成する
  ///
  /// [title] プレースホルダーに表示するテキスト情報
  /// [textEditingController] テキストフィールドコントローラ
  ///
  /// 戻り値::[TextFormField]ウィジェット
  ///
  Widget _textBox(String title, TextEditingController textEditingController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          obscureText: title == "パスワード" ? true : false,
          controller: textEditingController,
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
  /// [email] メールアドレスのテキストフィールドコントローラ
  /// [password] パスワードのテキストフィールドコントローラ
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _loginButton(BuildContext context, Widget page,
      TextEditingController email, TextEditingController password) {
    return ElevatedButton(
      onPressed: () async {
        debugPrint("login buttonクリック");

        FirebaseAuthentication firebaseAuth = FirebaseAuthentication();
        await firebaseAuth.authenticateWithPassword(email.text, password.text);

        if (context.mounted) {
          _navigate(context, page);
        } else {
          return;
        }

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
      onPressed: () async {
        debugPrint("Google login buttonクリック");

        FirebaseAuthentication firebaseAuth = FirebaseAuthentication();
        await firebaseAuth.authenticateWithGoogle();

        if (context.mounted) {
          _navigate(context, page);
        } else {
          return;
        }

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
  Widget _linkForgetPassword(BuildContext context, Widget page) {
    return InkWell(
      onTap: () {
        debugPrint("aaa");
        _navigate(context, page);
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
  /// [email] メールアドレスのテキストフィールドコントローラ
  /// [password] パスワードのテキストフィールドコントローラ
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _registerButton(BuildContext context, Widget page,
      TextEditingController email, TextEditingController password) {
    return ElevatedButton(
      onPressed: () async {
        debugPrint("register buttonクリック");

        FirebaseAuthentication firebaseAuth = FirebaseAuthentication();
        await firebaseAuth.registerWithPassword(email.text, password.text);

        if (context.mounted) {
          _navigate(context, page);
        } else {
          return;
        }

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
