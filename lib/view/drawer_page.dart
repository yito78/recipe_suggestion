import 'package:flutter/material.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage(BuildContext callersContext, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shadowColor: Colors.black26,
      width: MediaQuery.of(context).size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: const [
            Text(
              "オプションメニュー",
              style: TextStyle(decoration: TextDecoration.underline),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text("ログアウト"),
            )
          ],
        ),
      ),
    );
  }
}
