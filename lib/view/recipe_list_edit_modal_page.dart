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
  int? defaultDropdownValue;
  List<Map<String, dynamic>> ctgList = [];

  @override
  void initState() {
    super.initState();
    ctgList = widget.categoryDataList;
    defaultDropdownValue = ctgList[0]["category_id"];
    print("@@@@@@@@@@@@@@$ctgList");
    print("@@@@@@@@@@@@@@$defaultDropdownValue");
  }

  @override
  Widget build(BuildContext context) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;
    // ドロップダウンメニュー
    print(defaultDropdownValue);
    // // テキストフィールドコントローラ
    // TextEditingController textController = TextEditingController(
    //     text: widget.recipeAndCategoryList[1]);

    return AlertDialog(
      title: Text("レシピ編集"),
      content: Column(
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
            // items: [
            //   DropdownMenuItem(
            //     child: Text("$defaultDropdownValue"),
            //     value: defaultDropdownValue,
            //   ),
            //   DropdownMenuItem(child: Text("テスト"), value: "テスト",),
            //   DropdownMenuItem(child: Text("テスト２"), value: "テスト２",),
            // ],

            // items: ctgList.map<DropdownMenuItem<Map<String, dynamic>>>((String value) {
            //   return DropdownMenuItem<String>(
            //     value: value,
            //     child: Text("$value"),
            //   );
            // }).toList(),

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
    );
  }
}


// class RecipeListEditModalPage {
//
//   //
//   // ボタンクリック時に表示されるモーダル画面
//   //
//   // context::BuilderContextクラスオブジェクト
//   // recipeCategoryList::カテゴリ、レシピ名の1次元配列
//   //
//   Future<void> popEditModal(context, recipeCategoryList) async {
//     // 横幅定義用データ
//     var screenSize = MediaQuery.of(context).size;
//
//     // ドロップダウンメニュー
//     String defaultDropdownValue = recipeCategoryList[0];
//
//     // テキストフィールドコントローラ
//     final categoryController = TextEditingController();
//     final recipeController = TextEditingController();
//     TextEditingController textController = TextEditingController(text: recipeCategoryList[1]);
//
//     await showDialog(
//       context: context,
//       builder: (BuildContext context) {    return AlertDialog(
//         title: const Text('レシピ編集'),
//         content: Column(
//           children: [
//             Row(
//               children: [
//                 // タイトル
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Container(
//                     width: screenSize.width * 0.20,
//                     child: const Text("カテゴリ名"),
//                   ),
//                 ),
//                 // データ(カテゴリ名)
//                 // Expanded(
//                 //   child: DropdownButton<String>(
//                 //     value: defaultDropdownValue,
//                 //     onChanged: (String newValue) {
//                 //       dropdownValue = newValue;
//                 //     },
//                 //     items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4']
//                 //         .map<DropdownMenuItem<String>>((String value) {
//                 //       return DropdownMenuItem<String>(
//                 //         value: value,
//                 //         child: Text(value),
//                 //       );
//                 //     }).toList(),
//                 //   ),
//                 // ),
//               ],
//             ),
//             Row(
//               children: [
//                 // タイトル
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10.0),
//                   child: Container(
//                     width: screenSize.width * 0.20,
//                     child: const Text("レシピ名"),
//                   ),
//                 ),
//                 // データ(レシピ名)
//                 Expanded(
//                   child: TextField(controller: textController),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               // 更新ボタンが押された時の処理
//             },
//             child: Text("更新"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // 閉じるボタンが押された時の処理
//               Navigator.of(context).pop();
//             },
//             child: Text("閉じる"),
//           ),
//         ],
//       );
//       },
//     );
//   }
// }
