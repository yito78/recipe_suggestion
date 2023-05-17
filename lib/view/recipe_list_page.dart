import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/provider/categories_data.dart';
import 'package:recipe_suggestion/utils/log.dart';

import '../provider/recipes_data.dart';

class RecipeListPage extends ConsumerWidget {
  const RecipeListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _outputAccessLog();

    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    // recipesデータの監視
    final recipesWatch = ref.watch(recipesDataNotifierProvider);

    // 監視データからデータ抽出
    AsyncValue<List<Map<String, dynamic>>> fetchedRecipesData =
        recipesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      _outputErrorLog(e, s);
      return AsyncValue.error(e, s);
    }, loading: () {
      return AsyncValue.loading();
    });

    List<Map<String, dynamic>> recipeList = [];
    fetchedRecipesData.value?.forEach((data) {
      recipeList.add(data);
    });

    // categoriesデータの監視
    final categoriesWatch = ref.watch(categoriesDataNotifierProvider);

    // 監視データからデータ抽出
    AsyncValue<List<Map<String, dynamic>>> fetchedCategoriesData =
    categoriesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      _outputErrorLog(e, s);
      return AsyncValue.error(e, s);
    }, loading: () {
      return AsyncValue.loading();
    });

    List<Map<String, dynamic>> categoryList = [];
    fetchedCategoriesData.value?.forEach((data) {
      categoryList.add(data);
    });

    // カテゴリ名を抽出し、レシピ名とセットでデータを取得する
    List<List<String>> recipeCategoryList = [];
    _mergeRecipeNameCategoryName(recipeCategoryList, recipeList, categoryList);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("登録済レシピ一覧")),
      ),
      body: recipeCategoryList.isEmpty ? Text("レシピデータを登録してください") : ListView.builder(
          itemCount: recipeCategoryList.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              children: [
                SizedBox(
                  width: 80.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("${recipeCategoryList[index][0]}"),
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.425,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text("${recipeCategoryList[index][1]}"),
                  ),
                ),
                // ボタンオブジェクトを右寄せするため
                const Expanded(child: SizedBox()),
                _button("編集"),
                _button("削除"),
              ],
            );
          }),
    );
    // return const Text("登録済みレシピ一覧画面");
  }

  //
  //
  //
  Widget _button(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton(
        onPressed: null,
        child: Text(text),
      )
    );
  }
  //
  // 機能にアクセスされたことをアナリティクスログとして出力する
  //
  _outputAccessLog() {
    Log log = Log();
    log.accessLog(runtimeType.toString());
  }

  //
  // エラー発生内容をアナリティクスログとして出力する
  //
  // e::エラークラス
  // s::スタックトレース
  //
  _outputErrorLog(e, s) {
    Log log = Log();
    log.errorLog(runtimeType.toString(), e, s);
  }

  //
  List<List<String>> _mergeRecipeNameCategoryName(
      List<List<String>> recipeCategoryList,
      List<Map<String, dynamic>> recipeList,
      List<Map<String, dynamic>> categoryList) {
    
    recipeList.forEach((data) {
      String name = data["name"];
      String category = "";

      categoryList.forEach((categoryData) {
        if (categoryData["category_id"] == data["category"]) {
          category = categoryData["name"];
        }
      });
      recipeCategoryList.add([category, name]);
    });

    return recipeCategoryList;
  }
}
