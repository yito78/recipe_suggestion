import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';

/// 登録済みレシピ一覧画面の削除ボタンクリック時のモーダル画面クラス
class RecipeListDeleteModalPage extends StatefulWidget {
  final List<String> recipeAndCategoryList;
  final List<Map<String, dynamic>> categoryDataList;

  const RecipeListDeleteModalPage(
      {Key? key,
      required this.recipeAndCategoryList,
      required this.categoryDataList})
      : super(key: key);

  @override
  State<RecipeListDeleteModalPage> createState() =>
      _RecipeListDeleteModalPageState();
}

class _RecipeListDeleteModalPageState extends State<RecipeListDeleteModalPage> {
  String categoryLabel = "";
  String recipeLabel = "";
  int? categoryValue;
  TextEditingController recipeTextFieldValue = TextEditingController();

  var deleteExplainText = '''
  削除してもよろしいでしょうか
  その場合、削除ボタンをクリック
  してください
  ''';

  @override
  void initState() {
    super.initState();
    categoryValue = _fetchCategoryId(
        widget.categoryDataList, widget.recipeAndCategoryList[0]);
    categoryLabel = widget.recipeAndCategoryList[0];
    recipeLabel = widget.recipeAndCategoryList[1];
    recipeTextFieldValue.text = widget.recipeAndCategoryList[1];
  }

  @override
  Widget build(BuildContext context) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Center(child: Text("レシピ削除")),
      content: SizedBox(
        height: screenSize.height * 0.3,
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    width: screenSize.width * 0.20,
                    child: const Text("カテゴリ名"),
                  ),
                ),
                SizedBox(
                  child: Text(categoryLabel),
                )
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SizedBox(
                    width: screenSize.width * 0.20,
                    child: const Text("レシピ名"),
                  ),
                ),
                SizedBox(
                  child: Text(recipeLabel),
                )
              ],
            ),
            SizedBox(
              height: screenSize.height * 0.05,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(deleteExplainText)),
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
                onPressed: () async {
                  // 削除ボタンが押された時の処理
                  Firebase firebase = Firebase();
                  await firebase.deleteRecipes(recipeLabel, categoryValue);
                  Navigator.of(context).pop(true);
                },
                child: const Text("削除"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  // 閉じるボタンが押された時の処理
                  Navigator.of(context).pop(false);
                },
                child: const Text("キャンセル"),
              ),
            ),
          ],
        )
      ],
    );
  }

  _fetchCategoryId(List<Map<String, dynamic>> ctgList, recipeAndCategoryList) {
    int categoryId = 0;

    ctgList.forEach((data) {
      if (data["name"] == recipeAndCategoryList) {
        categoryId = data["category_id"];
        return;
      }
    });

    return categoryId;
  }
}
