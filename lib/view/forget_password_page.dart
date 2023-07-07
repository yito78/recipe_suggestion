import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:recipe_suggestion/view/login_page.dart';

/// パスワード再発行ページ
class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final TextEditingController emailTextEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("パスワード再発行"),
      ),
      body: Column(children: [
        _textBox("メールアドレス", emailTextEditController),
        const SizedBox(height: 20.0),
        _reissuePasswordButton(
            context, const LoginPage(), emailTextEditController)
      ]),
    );
  }

  ///
  /// テキスト入力エリアを作成する
  ///
  /// [title] プレースホルダーに表示するテキスト情報
  /// [textEditingController] テキストフィールドコントローラ
  ///
  /// 戻り値::TextFormFieldウィジェット
  ///
  Widget _textBox(String title, TextEditingController textEditingController) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          controller: textEditingController,
          decoration: InputDecoration(
            labelText: "$titleを入力してください",
          ),
        ));
  }

  ///
  /// パスワード再発行ボタンを作成する
  ///
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  /// [emailTextEditingController] emailアドレスのテキストフィールドコントロール
  ///
  /// 戻り値::ボタンウィジェット
  ///
  Widget _reissuePasswordButton(BuildContext context, Widget page,
      TextEditingController emailTextEditingController) {
    return ElevatedButton(
      onPressed: () async {
        debugPrint("パスワード再発行 buttonクリック");

        FirebaseAuthentication firebaseAuth = FirebaseAuthentication();
        await firebaseAuth.reissuePassword(emailTextEditingController.text);

        if (context.mounted) {
          _navigate(context, page);
        } else {
          return;
        }
      },
      child: const Text("パスワード再発行する"),
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
