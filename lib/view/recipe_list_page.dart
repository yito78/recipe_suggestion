import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/data/recipe.dart';
import 'package:recipe_suggestion/data/recipe_list_data.dart';
import 'package:recipe_suggestion/provider/categories_data.dart';
import 'package:recipe_suggestion/utils/log.dart';
import 'package:recipe_suggestion/view/recipe_list_delete_modal_page.dart';
import 'package:recipe_suggestion/view/recipe_list_edit_modal_page.dart';
import 'package:recipe_suggestion/view/recipe_list_register_modal_page.dart';

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
    AsyncValue<List<Recipe>> fetchedRecipesData = recipesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      _outputErrorLog(e, s);
      return AsyncValue.error(e, s);
    }, loading: () {
      return AsyncValue.loading();
    });

    List<Recipe> recipeList = [];
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

    RecipeListData recipeListData = RecipeListData();
    List<Recipe> sortedRecipeList =
        recipeListData.sort(recipeList, categoryList.length);

    // カテゴリ名を抽出し、レシピ名とセットでデータを取得する
    List<List<String>> recipeCategoryList = [];
    recipeListData.mergeRecipeNameCategoryName(
        recipeCategoryList, sortedRecipeList, categoryList);

    ///
    /// モーダル画面でfirestoreにデータ操作した際に、
    /// 一覧画面に最新情報を表示するためにfirestoreからデータ再取得する処理
    ///
    reacquireRecipeData() {
      // データ作成処理
      final recipeNotifier = ref.read(recipesDataNotifierProvider.notifier);
      recipeNotifier.fetchRecipeDataState();
    }

    Widget insertButton(context, categoryList) {
      return FloatingActionButton(
        onPressed: () async {
          final isReloadSelected = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListRegisterModalPage(
                    categoryDataList: categoryList);
              });
          if (isReloadSelected) {
            print("更新ボタンがクリックされました");
            reacquireRecipeData();
          } else {
            print("閉じるボタンがクリックされました");
          }
        },
        tooltip: "データ登録",
        child: const Icon(Icons.add),
      );
    }

    //
    // 編集ボタンウィジェット
    //
    // text::ボタン表示用テキスト
    // context::BuilderContextクラスのオブジェクト
    // recipeCategoryList::カテゴリ、レシピ名の1次元配列
    //
    Widget editButton(String text, context, recipeCategoryList, categoryList) {
      return ElevatedButton(
        onPressed: () async {
          final isReloadSelected = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListEditModalPage(
                    recipeAndCategoryList: recipeCategoryList,
                    categoryDataList: categoryList);
              });

          if (isReloadSelected) {
            print("更新ボタンをクリックしました");
            reacquireRecipeData();
          } else {
            print("閉じるボタンをクリックしました");
          }
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(const Size(20, 20)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // 角の丸さを指定
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white24),
          elevation: MaterialStateProperty.all<double>(0),
        ),
        child: const Icon(
          Icons.edit,
          size: 20.0,
          color: Colors.blue,
        ),
      );
    }

    //
    // 削除ボタンウィジェット
    //
    // text::ボタン表示用テキスト
    // context::BuilderContextクラスのオブジェクト
    // recipeCategoryList::カテゴリ、レシピ名の1次元配列
    //
    Widget deleteButton(
        String text, context, recipeCategoryList, categoryList) {
      return ElevatedButton(
        onPressed: () async {
          final isReloadSelected = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListDeleteModalPage(
                    recipeAndCategoryList: recipeCategoryList,
                    categoryDataList: categoryList);
              });
          if (isReloadSelected) {
            print("削除ボタンをクリックしました");
            reacquireRecipeData();
          } else {
            print("閉じるボタンをクリックしました");
          }
        },
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all<Size>(const Size(20, 20)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0), // 角の丸さを指定
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white24),
          elevation: MaterialStateProperty.all<double>(0),
        ),
        child: const Icon(
          Icons.delete,
          size: 20.0,
          color: Colors.blue,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("登録済レシピ一覧")),
      ),
      body: recipeCategoryList.isEmpty
          ? const Text("レシピデータを登録してください")
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: recipeCategoryList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                // カテゴリ名
                                SizedBox(
                                  width: screenSize.width * 0.20,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child:
                                        Text("${recipeCategoryList[index][0]}"),
                                  ),
                                ),
                                // レシピ名
                                SizedBox(
                                  width: screenSize.width * 0.425,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child:
                                        Text("${recipeCategoryList[index][1]}"),
                                  ),
                                ),
                                // ボタンオブジェクトを右寄せするため
                                const Expanded(child: SizedBox()),
                                editButton("編集", context,
                                    recipeCategoryList[index], categoryList),
                                deleteButton("削除", context,
                                    recipeCategoryList[index], categoryList),
                              ],
                            ),
                            const Divider(
                              height: 0.5,
                              color: Colors.grey,
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
      floatingActionButton: insertButton(context, categoryList),
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
}
