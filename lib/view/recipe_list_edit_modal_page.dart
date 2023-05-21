import 'package:flutter/material.dart';

// 登録済みレシピ一覧画面の編集ボタンクリック時のモーダル画面クラス
class RecipeListEditModalPage extends StatefulWidget {
  List<String> recipeAndCategoryList;
  List<Map<String, dynamic>> categoryDataList;

  RecipeListEditModalPage({Key? key, required this.recipeAndCategoryList, required this.categoryDataList })
      : super(key: key);

  @override
  State<RecipeListEditModalPage> createState() =>
      _RecipeListEditModalPageState();
}

class _RecipeListEditModalPageState extends State<RecipeListEditModalPage> {
  List<Map<String, dynamic>> ctgList = [];
  int? defaultDropdownValue;
  TextEditingController recipeTextFieldValue = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("@@@@@@@@@@${widget.categoryDataList}");
    ctgList = widget.categoryDataList;
    defaultDropdownValue = _fetchCategoryId(ctgList, widget.recipeAndCategoryList[0]);
    recipeTextFieldValue.text = widget.recipeAndCategoryList[1];
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

  _fetchCategoryId(List<Map<String, dynamic>> ctgList, String recipeAndCategoryList) {
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
