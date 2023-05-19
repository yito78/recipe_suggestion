import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/provider/categories_data.dart';
import 'package:recipe_suggestion/utils/log.dart';
import 'package:recipe_suggestion/view/recipe_list_delete_modal_page.dart';
import 'package:recipe_suggestion/view/recipe_list_edit_modal_page.dart';

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
      body: recipeCategoryList.isEmpty
          ? Text("レシピデータを登録してください")
          : ListView.builder(
              itemCount: recipeCategoryList.length,
              itemBuilder: (BuildContext context, int index) {
                return Row(
                  children: [
                    // カテゴリ名
                    SizedBox(
                      width: 80.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text("${recipeCategoryList[index][0]}"),
                      ),
                    ),
                    // レシピ名
                    SizedBox(
                      width: screenSize.width * 0.425,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text("${recipeCategoryList[index][1]}"),
                      ),
                    ),
                    // ボタンオブジェクトを右寄せするため
                    const Expanded(child: SizedBox()),
                    _editButton("編集", context, recipeCategoryList[index], categoryList),
                    _deleteButton("削除", context, recipeCategoryList[index], categoryList),
                  ],
                );
              }),
    );
    // return const Text("登録済みレシピ一覧画面");
  }

  //
  // 編集ボタンウィジェット
  //
  // text::ボタン表示用テキスト
  // context::BuilderContextクラスのオブジェクト
  // recipeCategoryList::カテゴリ、レシピ名の1次元配列
  //
  Widget _editButton(String text, context, recipeCategoryList, categoryList) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListEditModalPage(recipeAndCategoryList: recipeCategoryList, categoryDataList: categoryList);
              }
            );
          },
          child: Text(text),
        )
    );
  }

  //
  // 削除ボタンウィジェット
  //
  // text::ボタン表示用テキスト
  // context::BuilderContextクラスのオブジェクト
  // recipeCategoryList::カテゴリ、レシピ名の1次元配列
  //
  Widget _deleteButton(String text, context, recipeCategoryList, categoryList) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RecipeListDeleteModalPage(recipeAndCategoryList: recipeCategoryList, categoryDataList: categoryList);
                }
            );
          },
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
  // レシピとカテゴリ情報を統合し、配列データとして返却する
  //
  // recipeCategoryList::データ格納用配列
  // recipeList::firestoreから取得したレシピ情報
  // categoryList::firestoreから取得したカテゴリ情報
  //
  // 戻り値::カテゴリ, レシピの2次元配列
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
