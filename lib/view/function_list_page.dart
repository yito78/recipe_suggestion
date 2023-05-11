import 'package:flutter/material.dart';
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
            _button(context, SuggestedRecipePage(), const Text("1週間のレシピ一覧")),
            // ElevatedButton(onPressed: () { _navigate(context, SuggestedRecipePage()); }, child: const Text("1週間のレシピ一覧"),),
            _button(context, RecipeListPage(), const Text("登録レシピ一覧")),
            // ElevatedButton(onPressed: () { _navigate(context, RecipeListPage()); }, child: const Text("登録レシピ一覧"),),
            _button(context, ImportCsvPage(), const Text("CSVファイルデータ登録")),
            // ElevatedButton(onPressed: () { _navigate(context, ImportCsvPage()); }, child: const Text("CSVファイルデータ登録"),),
          ],
        ),
      ),
    );
  }

  Widget _button(context, page, text) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Center(
        child: SizedBox(
          width: screenSize.width * 0.8,
          child: ElevatedButton(
              onPressed: () {
                _navigate(context, page);
              },
              child: page),
        ),
      ),
    );
  }

  _navigate(context, page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
