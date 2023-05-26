import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';

// 登録済みレシピ一覧画面の登録ボタンクリック時のモーダル画面クラス
class RecipeListRegisterModalPage extends StatefulWidget {
  List<Map<String, dynamic>> categoryDataList;

  RecipeListRegisterModalPage({Key? key, required this.categoryDataList })
      : super(key: key);

  @override
  State<RecipeListRegisterModalPage> createState() =>
      _RecipeListRegisterModalPageState();
}

class _RecipeListRegisterModalPageState extends State<RecipeListRegisterModalPage> {
  List<Map<String, dynamic>> ctgList = [];
  int? defaultDropdownValue;
  TextEditingController recipeTextFieldValue = TextEditingController();


  @override
  void initState() {
    super.initState();
    ctgList = widget.categoryDataList;
    defaultDropdownValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Center(child: Text("レシピ編集")),
      content: Container(
        height: screenSize.height * 0.3,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: screenSize.width * 0.20,
                    child: const Text("カテゴリ名"),
                  ),
                ),
                DropdownButton<int?>(
                  value: defaultDropdownValue,
                  items: ctgList.map((item) {
                    return DropdownMenuItem<int?>(
                      value: item["category_id"],
                      child: Text(item["name"]),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      defaultDropdownValue = value!;
                    });
                  },
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: screenSize.width * 0.20,
                    child: const Text("レシピ名"),
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.40,
                  child: TextFormField(
                    controller: recipeTextFieldValue,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  // 更新ボタンが押された時の処理
                  _insert(context);
                },
                child: const Text("更新"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  // 閉じるボタンが押された時の処理
                  Navigator.of(context).pop();
                },
                child: const Text("キャンセル"),
              ),
            ),
          ],
        )
      ],
    );
  }

  //
  // firebaseにデータ登録する
  //
  void _insert(context) {
    Firebase firebase = Firebase();
    firebase.insertRecipes(recipeTextFieldValue.text, defaultDropdownValue);
    Navigator.of(context).pop("@@@");
  }
}
