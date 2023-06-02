import 'package:flutter/material.dart';

class WeeklyRecipeModalPage extends StatelessWidget {
  const WeeklyRecipeModalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text("本当にレシピ情報を更新してもよろしいですか？"),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop("@@@"),
              child: const Text("更新"),
            ),
            const SizedBox(width: 10.0,),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("キャンセル"),
            ),
          ],
        ),
      ],
    );
  }
}
