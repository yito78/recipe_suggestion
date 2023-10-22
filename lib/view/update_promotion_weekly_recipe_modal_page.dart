import 'package:flutter/material.dart';

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
              onPressed: () => Navigator.of(context).pop("@@@"),
              child: const Text("更新"),
            ),
            const SizedBox(
              width: 10.0,
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("いいえ"),
            ),
          ],
        ),
      ],
    );
  }
}
