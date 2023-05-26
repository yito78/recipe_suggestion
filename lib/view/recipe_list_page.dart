import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    List<Map<String, dynamic>> sortedRecipeList =
        _sort(recipeList, categoryList.length);

    // カテゴリ名を抽出し、レシピ名とセットでデータを取得する
    List<List<String>> recipeCategoryList = [];
    _mergeRecipeNameCategoryName(
        recipeCategoryList, sortedRecipeList, categoryList);

    ///
    /// モーダル画面でfirestoreにデータ操作した際に、
    /// 一覧画面に最新情報を表示するためにfirestoreからデータ再取得する処理
    ///
    regetRecipeData() {
      // データ作成処理
      final recipeNotifier = ref.read(recipesDataNotifierProvider.notifier);
      recipeNotifier.fetchRecipeDataState();
    }

    Widget _insertButton(context, categoryList) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListRegisterModalPage(
                  categoryDataList: categoryList
                );
              }
          ).then((value) {
            if (value != null) {
              print("更新ボタンがクリックされました");
              regetRecipeData();
            } else {
              print("閉じるボタンがクリックされました");
            }
          });
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
    Widget _editButton(String text, context, recipeCategoryList, categoryList) {
      return ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListEditModalPage(
                    recipeAndCategoryList: recipeCategoryList,
                    categoryDataList: categoryList);
              }
          ).then((value) {
            if (value != null) {
              print("更新ボタンをクリックしました");
              regetRecipeData();
            } else {
              print("閉じるボタンをクリックしました");
            }
          });
        },
        child: const Icon(
          Icons.edit,
          size: 20.0,
          color: Colors.blue,
        ),
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
      return ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return RecipeListDeleteModalPage(
                    recipeAndCategoryList: recipeCategoryList,
                    categoryDataList: categoryList);
              }
          ).then((value) {
            if (value != null) {
              print("削除ボタンをクリックしました");
              regetRecipeData();
            } else {
              print("閉じるボタンをクリックしました");
            }
          });
        },
        child: const Icon(
          Icons.delete,
          size: 20.0,
          color: Colors.blue,
        ),
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
                                _editButton("編集", context,
                                    recipeCategoryList[index], categoryList),
                                _deleteButton("削除", context,
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
      floatingActionButton: _insertButton(context, categoryList),
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

  //
  // レシピ一覧情報をソートする
  //   第一ソートキー : カテゴリID
  //   第二ソートキー : レシピ名
  // dartのsortメソッドの仕様上、文字種が混在している場合、文字種内でのみソートを実施
  // (utf8の文字コードでソートしている)
  //
  // recipeList::レシピ情報(1次元配列)
  // categoryListLength::カテゴリ数
  //
  List<Map<String, dynamic>> _sort(
      List<Map<String, dynamic>> recipeList, categoryListLength) {
    // 第一ソートキー : カテゴリIDでソート
    recipeList.sort((a, b) {
      final sortByCategory = a["category"].compareTo(b["category"]);
      return sortByCategory;
    });

    // 第二ソート処理で使用する変数群
    int loopCount = 0;
    int categoryId = 0;
    bool lastCategoryInitFlg = true;
    List<List<Map<String, dynamic>>> sortedRecipeList = [];
    List<Map<String, dynamic>> tmpList = [];

    // 第二ソートキー : レシピ名でソート
    recipeList.forEach((data) {
      loopCount += 1;

      // カテゴリIDごとにデータを仕分けする
      if ((categoryId + 1) == categoryListLength) {
        // 1つめのデータ専用処理
        if (lastCategoryInitFlg == false) {
          // 初回のみの実行のため、flg切り替え
          lastCategoryInitFlg = true;
          tmpList.sort((a, b) => a["name"].compareTo(b["name"]));
          sortedRecipeList.add(tmpList);
          tmpList = [];
          // 初めのデータをロストさせないための処理
          tmpList.add(data);
        }

        // 2つめ以降のデータ追加処理
        tmpList.add(data);

        // 最後のデータについては、sortedRecipeListデータ格納を実施
        if (recipeList.length == loopCount) {
          tmpList.sort((a, b) => a["name"].compareTo(b["name"]));
          sortedRecipeList.add(tmpList);
        }
      } else if (categoryId == data["category"]) {
        tmpList.add(data);
        // 最後のカテゴリID群用の処理
      } else {
        tmpList.sort((a, b) => a["name"].compareTo(b["name"]));
        sortedRecipeList.add(tmpList);
        tmpList = [];
        // 初めのデータをロストさせないための処理
        tmpList.add(data);
        categoryId += 1;
      }
    });

    // 2次元配列を1次元配列に変換
    List<Map<String, dynamic>> sortedData =
        sortedRecipeList.expand((row) => row).toList();

    return sortedData;
  }
}
