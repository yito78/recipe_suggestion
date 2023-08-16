import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_suggestion/utils/firebase_auth_error.dart';
import 'package:recipe_suggestion/view/forget_password_page.dart';
import 'package:recipe_suggestion/view/function_list_page.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';

/// ログイン画面
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailTextEditController = TextEditingController();
  final TextEditingController passwordTextEditController =
      TextEditingController();

  @override

  ///
  /// [TextEditingController]のリソース破棄処理
  ///
  void dispose() {
    emailTextEditController.dispose();
    passwordTextEditController.dispose();
    super.dispose();
  }

  ///
  /// テキストフィールドの値をクリアする
  ///
  void clearTextFields() {
    emailTextEditController.clear();
    passwordTextEditController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recipe Suggestion"),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 30.0,
            ),
            _createTextBox("メールアドレス", emailTextEditController),
            const SizedBox(
              height: 10.0,
            ),
            _createTextBox("パスワード", passwordTextEditController,
                obscureText: true),
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
  /// [textEditingController] 作成するWidgetの子要素のTextFormFieldに紐づけるTextEditingController
  /// [obscureText] テキストフィールドの入力値を表示する場合はtrue / 非表示にする場合はfalse
  ///
  /// 戻り値::[TextFormField]ウィジェット
  ///
  Widget _createTextBox(
      String title, TextEditingController textEditingController,
      {bool obscureText = false}) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          obscureText: obscureText ? true : false,
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
        try {
          await firebaseAuth.authenticateWithPassword(
              email.text, password.text);
        } on FirebaseAuthException catch (e) {
          String errorMessage = FirebaseAuthError.getExceptionMessage(e);
          final snackBar = SnackBar(content: Text(errorMessage));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
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
        await firebaseAuth.authenticateWithGoogle().then((value) {
          debugPrint("ログインに成功");
        }).onError((error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ログイン処理に失敗しました'),
            ),
          );
        });
      },
      child: const Text("Googleアカウントログイン"),
    );
  }

  ///
  /// パスワード忘れリンクウィジェットを作成する
  ///
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  ///
  /// 戻り値::パスワード忘れリンクウィジェット
  ///
  Widget _linkForgetPassword(BuildContext context, Widget page) {
    return InkWell(
      onTap: () {
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
    setState(() {
      clearTextFields();
    });
  }
}
