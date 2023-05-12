import 'package:flutter/material.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
import 'package:recipe_suggestion/view/import_csv_page.dart';
import 'package:recipe_suggestion/view/recipe_list_page.dart';
import 'package:recipe_suggestion/view/suggested_recipe_page.dart';

class FunctionListPage extends StatelessWidget {
  const FunctionListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("機能一覧")),
        ),
        body: Column(
          children: [
            FutureBuilder<List>(
              future: _fetchRecipesData(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasError) {
                  return _button(context, SuggestedRecipePage(), const Text("1週間のレシピ一覧"), false);
                } else {
                  if (snapshot.data == null || snapshot.data?.length == 0) {
                    // recipesコレクションにデータがない場合、ボタン非活性にする
                    return _button(context, SuggestedRecipePage(), const Text("1週間のレシピ一覧"), false);
                  } else {
                    return _button(context, SuggestedRecipePage(), const Text("1週間のレシピ一覧"), true);
                  }
                }
              }
            ),
            _button(context, RecipeListPage(), const Text("登録レシピ一覧")),
            _button(context, ImportCsvPage(), const Text("CSVファイルデータ登録")),
          ],
        ),
      ),
    );
  }

  //
  // ボタンWidget作成
  //
  // context::build時のcontext
  // page::遷移先のページ
  // text::表示されるボタン名
  // isActived::ボタン活性状態制御フラグ(true: 活性状態、false: 非活性状態)
  //
  // 戻り値::ElevatedButton
  //
  Widget _button(context, page, text, [bool isActived = true]) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Center(
        child: SizedBox(
          width: screenSize.width * 0.8,
          child: ElevatedButton(
              onPressed: isActived ? () => _navigate(context, page) : null,
              child: text),
        ),
      ),
    );
  }

  //
  // 画面遷移処理
  //
  // context::build時のcontext
  // page::遷移先のページ
  //
  // 戻り値::なし
  //
  _navigate(context, page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  //
  // firestore recipesコレクションデータ取得
  //
  // 戻り値::recipesコレクションデータ
  //
  Future<List> _fetchRecipesData() async{
    Firebase firebase = Firebase();
    List<Map<String, dynamic>> data = await firebase.searchAllRecipes();

    return data;
  }
}
