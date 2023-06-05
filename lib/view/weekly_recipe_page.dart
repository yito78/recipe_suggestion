import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/provider/randomed_recipes_data.dart';
import 'package:recipe_suggestion/view/weekly_recipe_modal_page.dart';

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
    Map<String, String> dateByWeekday = _createWeeklyDateWeekday();

    print(dateByWeekday);

    // recipesデータの監視
    final recipesWatch = ref.watch(randomedRecipesDataNotifierProvider);

    // 監視データからデータ抽出
    AsyncValue<Map<int, List<dynamic>>> fetchedRecipesData =
      recipesWatch.when(
        data: (d) {
          return AsyncValue.data(d);
        },
        error: (e, s) {
          return AsyncValue.error(e, s);
        },
        loading: () {
          return AsyncValue.loading();
        }
      );

    ///
    /// モーダル画面でfirestoreにデータ操作した際に、
    /// 一覧画面に最新情報を表示するためにfirestoreからデータ再取得する処理
    ///
    regetRecipeData() {
      // データ作成処理
      final randomedRecipesDataNotifier = ref.read(randomedRecipesDataNotifierProvider.notifier);
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
                  }
              );

              if (value != null) {
                regetRecipeData();
                print("更新ボタンがクリックされました");
              } else {
                print("閉じるボタンがクリックされました");
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
              _cardWidget("月曜日", setHeight, imagePath, fetchedRecipesData),
              _cardWidget("火曜日", setHeight, imagePath, fetchedRecipesData),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("水曜日", setHeight, imagePath, fetchedRecipesData),
              _cardWidget("木曜日", setHeight, imagePath, fetchedRecipesData),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("金曜日", setHeight, imagePath, fetchedRecipesData),
              _cardWidget("土曜日", setHeight, imagePath, fetchedRecipesData),
            ],
          ),
          TableRow(
            children: [
              _cardWidget("日曜日", setHeight, imagePath, fetchedRecipesData),
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
  ///
  /// 戻り値::月曜から日曜までのレシピ表示領域ウィジェット
  ///
  Widget _cardWidget(weekdayText, setHeight, imagePath, recipeByCategoryId) {
    Map<String, int> selectTargetIndex = {
      "月曜日": 0,
      "火曜日": 1,
      "水曜日": 2,
      "木曜日": 3,
      "金曜日": 4,
      "土曜日": 5,
      "日曜日": 6,
    };

    return SizedBox(
        height: setHeight,
        child: Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    weekdayText,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _titleAndRecipeName(imagePath["main"], "主菜レシピ名", recipeByCategoryId.value == null ? "" : recipeByCategoryId.value[0][selectTargetIndex[weekdayText]]),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _titleAndRecipeName(imagePath["sub"], "副菜レシピ名", recipeByCategoryId.value == null ? "" : recipeByCategoryId.value[1][selectTargetIndex[weekdayText]]),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _titleAndRecipeName(imagePath["dessert"], "デザートレシピ名", recipeByCategoryId.value == null ? "" : recipeByCategoryId.value[2][selectTargetIndex[weekdayText]]),
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
            child: Image.asset(imagePath, width: 14.0, height: 14.0,)
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(recipeData, style: const TextStyle(fontSize: 12.0),),
        ),
      ],
    );
  }

  ///
  /// 1週間分の日付と曜日のハッシュ情報作成処理
  ///
  /// 戻り値::
  ///   {
  ///     "月曜日": "yyyy/mm/dd"
  ///     "火曜日": "yyyy/mm/dd"
  ///     "水曜日": "yyyy/mm/dd"
  ///     "木曜日": "yyyy/mm/dd"
  ///     …
  ///   }
  ///
  Map<String, String> _createWeeklyDateWeekday() {
    DateTime datetime = DateTime.now();
    int weekdayInt = datetime.weekday;

    Map<String, String> weeklyDateWeekday = {
      "月曜日": _calclateDate(datetime, 1, weekdayInt),
      "火曜日": _calclateDate(datetime, 2, weekdayInt),
      "水曜日": _calclateDate(datetime, 3, weekdayInt),
      "木曜日": _calclateDate(datetime, 4, weekdayInt),
      "金曜日": _calclateDate(datetime, 5, weekdayInt),
      "土曜日": _calclateDate(datetime, 6, weekdayInt),
      "日曜日": _calclateDate(datetime, 7, weekdayInt),
    };


    return weeklyDateWeekday;
  }

  ///
  /// 基準曜日(アプリ利用日)をもとに該当週の日付を計算する
  /// 計算対象曜日が基準曜日以前である場合、基準曜日の日付から減算する
  /// 逆の場合は、基準曜日の日付に対して加算する
  ///
  ///   例
  ///     基準曜日(アプリ利用日)が水曜日で、計算対象曜日が月曜日の場合の計算について
  ///     水曜日のDateTime.weekday : 3
  ///     月曜日のDateTime.weekday : 1
  ///       3 - 1 = 2
  ///     水曜日のDateTime.nowから2日前として計算する
  ///
  ///     基準曜日(アプリ利用日)が水曜日で、計算対象曜日が木曜日の場合の計算について
  ///     水曜日のDateTime.weekday : 3
  ///     木曜日のDateTime.weekday : 4
  ///       4 - 3 = 1
  ///     水曜日のDateTime.nowから1日後として計算する
  ///
  /// datetime::DateTimeオブジェクト
  /// calcTargetWeekday::計算対象曜日(月曜なら1, 火曜なら2…)
  /// baseWeekday::基準曜日(月曜なら1, 火曜なら2…)
  ///
  String _calclateDate(DateTime datetime, int calcTargetWeekday, int baseWeekday) {
    if (baseWeekday >= calcTargetWeekday) {
      DateTime calclatedDate = datetime.subtract(Duration(days: baseWeekday - calcTargetWeekday));
      return "${calclatedDate.year}/${calclatedDate.month}/${calclatedDate.day}";
    } else {
      DateTime calclatedDate = datetime.add(Duration(days: calcTargetWeekday - baseWeekday));
      return "${calclatedDate.year}/${calclatedDate.month}/${calclatedDate.day}";
    }
  }
}
