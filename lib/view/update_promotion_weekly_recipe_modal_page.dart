import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';

class UpdatePromotionWeeklyRecipeModalPage extends StatelessWidget {
  const UpdatePromotionWeeklyRecipeModalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text(
          "今週のメニューを新規に設定しますか？\nその場合、更新ボタンをクリックしてください。\n前回のメニューを継続する場合はいいえボタンをクリックしてください。"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 登録データを今週の日付で再登録する
                Firebase firebase = Firebase();
                await firebase.insertWeeklyMenu();

                Navigator.of(context).pop("@@@");
              },
              child: const Text("更新"),
            ),
            const SizedBox(
              width: 10.0,
            ),
            ElevatedButton(
              onPressed: () async {
                // 登録データを今週の日付で再登録する
                Firebase firebase = Firebase();
                await firebase.insertWeeklyMenu(true);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("いいえ"),
            ),
          ],
        ),
      ],
    );
  }
}
