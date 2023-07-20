import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';
import 'package:recipe_suggestion/view/login_page.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: const Color.fromARGB(255, 230, 230, 230),
      ),
      child: Drawer(
        shadowColor: Colors.black26,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              const Text(
                "オプションメニュー",
                style: TextStyle(decoration: TextDecoration.underline),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: _createLogoutLink(context),
              )
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// ログアウトリンクのウィジェットを作成する
  ///
  /// [context] build時のcontext
  ///
  /// 戻り値::パスワード忘れリンクウィジェット
  ///
  Widget _createLogoutLink(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (_) {
              return _createAlertDialog(context);
            });
      },
      child: const Text("ログアウト"),
    );
  }

  ///
  /// ログアウト用のアラート画面を作成する
  ///
  /// [context] BuildContextクラスのオブジェクト
  ///
  /// 戻り値::アラート画面
  ///
  Widget _createAlertDialog(BuildContext context) {
    return AlertDialog(
      title: const Text("ログアウトしてもよろしいですか？"),
      actions: <Widget>[
        GestureDetector(
          child: const Text("いいえ"),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        GestureDetector(
          // ログアウト処理
          onTap: () async {
            FirebaseAuthentication firebase = FirebaseAuthentication();
            await firebase.signOut();

            if (context.mounted) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            }
          },
          child: const Text("はい"),
        )
      ],
    );
  }
}
