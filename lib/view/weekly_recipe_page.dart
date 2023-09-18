import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/provider/randomed_recipes_data.dart';
import 'package:recipe_suggestion/provider/weekly_recipes_data.dart';
import 'package:recipe_suggestion/utils/weekly_recipe.dart';
import 'package:recipe_suggestion/view/weekly_recipe_modal_page.dart';

/// 1週間レシピ一覧画面
class WeeklyRecipePage extends ConsumerWidget {
  const WeeklyRecipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var screenSize = MediaQuery.of(context).size;
    var setHeight = screenSize.height * 0.22;
    Map<String, String> imagePath = {
      "main": "assets/images/main.png",
      "sub": "assets/images/sub.png",
      "dessert": "assets/images/dessert.png",
    };

    /// 1週間分の日付と曜日のハッシュ情報取得
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    Map<String, String> dateByWeekday = weeklyRecipe.createWeeklyDateWeekday();

    // weekly_recipesデータを監視する
    final weeklyRecipesWatch = ref.watch(weeklyRecipesDataNotifierProvider);
    // weekly_recipesデータを取得する
    final fetchedWeeklyRecipesData = weeklyRecipesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      return AsyncValue.error(e, s);
    }, loading: () {
      return const AsyncValue.loading();
    });

    ///
    /// モーダル画面でfirestoreにデータ操作した際に、
    /// 一覧画面に最新情報を表示するためにfirestoreからデータ再取得する処理
    ///
    regetRecipeData() {
      // データ作成処理
      final randomedRecipesDataNotifier =
          ref.read(randomedRecipesDataNotifierProvider.notifier);
      randomedRecipesDataNotifier.fetchRandomedRecipeDataState();
    }

    ///
    /// レシピ一覧の内容更新するボタンを生成
    ///
    /// setHeight::表示領域の高さ指定
    ///
    /// 戻り値::更新ボタンウィジェット
    ///
    Widget floatActionButton(setHeight, context) {
      return SizedBox(
        height: setHeight,
        child: Container(
          padding: const EdgeInsets.only(left: 100.0, top: 50.0),
          alignment: Alignment.center,
          child: FloatingActionButton(
            tooltip: "表示レシピの更新",
            onPressed: () async {
              final value = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const WeeklyRecipeModalPage();
                  });

              if (value != null) {
                regetRecipeData();
                debugPrint("更新ボタンがクリックされました");
              } else {
                debugPrint("閉じるボタンがクリックされました");
              }
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("1週間のレシピ一覧")),
      ),
      body: Table(
        children: [
          TableRow(
            children: [
              _cardWidget("月曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["月曜日"]),
              _cardWidget("火曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["火曜日"]),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("水曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["水曜日"]),
              _cardWidget("木曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["木曜日"]),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("金曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["金曜日"]),
              _cardWidget("土曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["土曜日"]),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("日曜日", setHeight, imagePath, fetchedWeeklyRecipesData,
                  dateByWeekday["日曜日"]),
              floatActionButton(setHeight, context),
            ],
          ),
        ],
      ),
    );
  }

  ///
  /// 月曜から日曜までのレシピ表示領域を作成
  ///
  /// weekdayText::画面表示する曜日のテキスト情報
  /// setHeight::表示領域の高さ指定
  /// imagePath::アイコン表示用パス
  /// fetchedWeeklyRecipesData::画面表示用レシピデータ
  /// displayDate::画面表示用日付(yyyy/mm/dd)
  ///
  /// 戻り値::月曜から日曜までのレシピ表示領域ウィジェット
  ///
  Widget _cardWidget(weekdayText, setHeight, imagePath,
      fetchedWeeklyRecipesData, displayDate) {
    List<String> selectTargetIndex = [
      "月曜日",
      "火曜日",
      "水曜日",
      "木曜日",
      "金曜日",
      "土曜日",
      "日曜日",
    ];

    List<dynamic> mainRecipes = [];
    List<dynamic> subRecipes = [];
    List<dynamic> desertRecipes = [];

    // 曜日に合致するレシピインデックスを取得する
    int recipeIndex = selectTargetIndex.indexOf(weekdayText);

    if (fetchedWeeklyRecipesData.value != null) {
      mainRecipes = fetchedWeeklyRecipesData.value[0]["0"]["recipes"];
      subRecipes = fetchedWeeklyRecipesData.value[0]["1"]["recipes"];
      desertRecipes = fetchedWeeklyRecipesData.value[0]["2"]["recipes"];
    }
    return SizedBox(
        height: setHeight,
        child: Card(
          child: Column(
            children: [
              _createCardHeader(weekdayText, displayDate),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _titleAndRecipeName(
                        imagePath["main"],
                        "主菜レシピ名",
                        fetchedWeeklyRecipesData.value == null
                            ? ""
                            : mainRecipes[recipeIndex]),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _titleAndRecipeName(
                        imagePath["sub"],
                        "副菜レシピ名",
                        fetchedWeeklyRecipesData.value == null
                            ? ""
                            : subRecipes[recipeIndex]),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _titleAndRecipeName(
                        imagePath["dessert"],
                        "デザートレシピ名",
                        fetchedWeeklyRecipesData.value == null
                            ? ""
                            : desertRecipes[recipeIndex]),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  ///
  /// カテゴリ名、レシピ名を表示するウィジェット
  ///
  /// imagePath::カテゴリイメージ画像パス
  /// recipe::レシピ名
  ///
  /// 戻り値::各カテゴリタイトル、レシピ名のウィジェット
  ///
  Widget _titleAndRecipeName(imagePath, recipe, recipeData) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                imagePath,
                width: 14.0,
                height: 14.0,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            recipeData,
            style: const TextStyle(fontSize: 12.0),
          ),
        ),
      ],
    );
  }

  ///
  /// 各曜日タイルのヘッダ箇所を作成する
  ///
  /// [weekdayText] 曜日テキスト
  /// [displayDate] 日付テキスト
  ///
  /// 戻り値::各曜日タイルのヘッダ
  ///
  Widget _createCardHeader(weekdayText, displayDate) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          weekdayText + "(" + displayDate + ")",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
