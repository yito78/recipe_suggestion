import 'package:flutter/material.dart';

class RecipeListEditModalPage extends StatefulWidget {
  // BuildContext context;
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
    ctgList = widget.categoryDataList;
    defaultDropdownValue = ctgList[0]["category_id"];
    recipeTextFieldValue.text = widget.recipeAndCategoryList[1];
  }

  @override
  Widget build(BuildContext context) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: Center(child: Text("レシピ編集")),
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
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: screenSize.width * 0.20,
                    child: Text("レシピ名"),
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
                child: Text("更新"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  // 閉じるボタンが押された時の処理
                  Navigator.of(context).pop();
                },
                child: Text("閉じる"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
