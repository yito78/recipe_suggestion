import 'package:flutter/material.dart';

// 登録済みレシピ一覧画面の削除ボタンクリック時のモーダル画面クラス
class RecipeListDeleteModalPage extends StatefulWidget {
  List<String> recipeAndCategoryList;
  List<Map<String, dynamic>> categoryDataList;

  RecipeListDeleteModalPage(
      {Key? key, required this.recipeAndCategoryList, required this.categoryDataList })
      : super(key: key);

  @override
  State<RecipeListDeleteModalPage> createState() =>
      _RecipeListDeleteModalPageState();
}

class _RecipeListDeleteModalPageState extends State<RecipeListDeleteModalPage> {
  String categoryLabel = "";
  String recipeLabel = "";
  TextEditingController recipeTextFieldValue = TextEditingController();

  var deleteExplainText = '''
  削除してもよろしいでしょうか
  その場合、削除ボタンをクリック
  してください
  ''';

  @override
  void initState() {
    super.initState();
    categoryLabel = widget.recipeAndCategoryList[0];
    recipeLabel = widget.recipeAndCategoryList[1];
    recipeTextFieldValue.text = widget.recipeAndCategoryList[1];
  }

  @override
  Widget build(BuildContext context) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Center(child: Text("レシピ削除")),
      content: Container(
        height: screenSize.height * 0.3,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: screenSize.width * 0.20,
                    child: Text("カテゴリ名"),
                  ),
                ),
                Container(
                  child: Text(categoryLabel),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: screenSize.width * 0.20,
                    child: Text("レシピ名"),
                  ),
                ),
                Container(
                  child: Text(recipeLabel),
                )
              ],
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(alignment: Alignment.centerLeft, child: Text(deleteExplainText)),),
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
                  // 削除ボタンが押された時の処理
                },
                child: Text("削除"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  // 閉じるボタンが押された時の処理
                  Navigator.of(context).pop();
                },
                child: Text("キャンセル"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
