import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
import 'package:recipe_suggestion/domain/repository/firebase_authentication.dart';

class UpdatePromotionWeeklyRecipeModalPage extends StatelessWidget {
  const UpdatePromotionWeeklyRecipeModalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text("今週のメニュー作成"),
      ),
      content: const Text(
          "今週のメニューを作成しますか？\nその場合、作成ボタンをクリックしてください。\n前回のメニューをコピーする場合はコピーボタンをクリックしてください。"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // 登録データを今週の日付で再登録する
                String? uid =
                    await FirebaseAuthentication.fetchSignedInUserId();
                Firebase firebase = Firebase();
                await firebase.insertWeeklyMenu(uid);
                if (context.mounted) {
                  Navigator.of(context).pop("@@@");
                }
              },
              child: const Text("作成"),
            ),
            const SizedBox(
              width: 10.0,
            ),
            ElevatedButton(
              onPressed: () async {
                // 登録データを今週の日付で再登録する
                String? uid =
                    await FirebaseAuthentication.fetchSignedInUserId();
                Firebase firebase = Firebase();
                await firebase.insertWeeklyMenu(uid, true);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("コピー"),
            ),
          ],
        ),
      ],
    );
  }
}
