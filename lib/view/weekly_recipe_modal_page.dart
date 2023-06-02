import 'package:flutter/material.dart';

class WeeklyRecipeModalPage extends StatelessWidget {
  const WeeklyRecipeModalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text("本当にレシピ情報を更新してもよろしいですか？"),
      actions: [
        ElevatedButton(
          onPressed: () {
            // TODO データ更新処理
            onPressed: () => Navigator.of(context).pop();
          },
          child: const Text("はい"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("いいえ"),
        ),
      ],
    );
  }
}
