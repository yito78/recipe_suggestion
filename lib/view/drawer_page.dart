import 'package:flutter/material.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage(BuildContext callersContext, {super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      child: ListView(
        children: const [
          Text("ログアウト"),
        ],
      ),
    );
  }
}
