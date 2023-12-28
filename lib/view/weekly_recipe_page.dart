import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/provider/randomed_recipes_data.dart';
import 'package:recipe_suggestion/provider/data_update_promotion.dart';
import 'package:recipe_suggestion/provider/weekly_recipes_data.dart';
import 'package:recipe_suggestion/utils/weekly_recipe.dart';
import 'package:recipe_suggestion/view/update_promotion_weekly_recipe_modal_page.dart';
import 'package:recipe_suggestion/view/weekly_recipe_modal_page.dart';

/// 1週間レシピ一覧画面
class WeeklyRecipePage extends ConsumerStatefulWidget {
  const WeeklyRecipePage({super.key});

  @override
  WeeklyRecipePageState createState() => WeeklyRecipePageState();
}

// 更新促進画面実施済みフラグ
late bool isExecutedPopupUpdatePromotion;

class WeeklyRecipePageState extends ConsumerState<WeeklyRecipePage> {
  @override
  void initState() {
    super.initState();

    isExecutedPopupUpdatePromotion = false;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var setHeight = screenSize.height * 0.22;
    Map<String, String> imagePath = _setImage();

    // 1週間分の日付と曜日のハッシュ情報取得
    WeeklyRecipe weeklyRecipe = WeeklyRecipe();
    Map<String, String> dateByWeekday = weeklyRecipe.createWeeklyDateWeekday();

    // 更新促進画面表示判定フラグデータを監視する
    final updatePromotionWatch = ref.watch(dataUpdatePromotionNotifierProvider);
    final isPopupUpdatePromotion = updatePromotionWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      return AsyncValue.error(e, s);
    }, loading: () {
      return const AsyncValue.loading();
    });

    final weeklyDate = weeklyRecipe.createWeeklyDate();

    // weekly_recipesデータを監視する
    final weeklyRecipesWatch = ref.watch(weeklyRecipesDataNotifierProvider);
    // weekly_recipesデータを取得する
    final weeklyMenuData = weeklyRecipesWatch.when(data: (d) {
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

    if (isPopupUpdatePromotion.value == null && weeklyMenuData.value == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("1週間のレシピ一覧(夕食)")),
        ),
        body: Container(),
      );
    } else {
      // 今週のレシピデータが存在しない場合、更新促進画面を表示する
      if (isExecutedPopupUpdatePromotion == false &&
          isPopupUpdatePromotion.value == true) {
        _executePopupUpdatePromotion(context, ref);
      }

      return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("1週間のレシピ一覧(夕食)")),
        ),
        body: Table(
          children: [
            TableRow(
              children: [
                _cardWidget(
                    "月曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["月曜日"],
                    weeklyDate[0],
                    isPopupUpdatePromotion.value),
                _cardWidget(
                    "火曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["火曜日"],
                    weeklyDate[1],
                    isPopupUpdatePromotion.value),
              ],
            ),
            TableRow(
              children: [
                _cardWidget(
                    "水曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["水曜日"],
                    weeklyDate[2],
                    isPopupUpdatePromotion.value),
                _cardWidget(
                    "木曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["木曜日"],
                    weeklyDate[3],
                    isPopupUpdatePromotion.value),
              ],
            ),
            TableRow(
              children: [
                _cardWidget(
                    "金曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["金曜日"],
                    weeklyDate[4],
                    isPopupUpdatePromotion.value),
                _cardWidget(
                    "土曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["土曜日"],
                    weeklyDate[5],
                    isPopupUpdatePromotion.value),
              ],
            ),
            TableRow(
              children: [
                _cardWidget(
                    "日曜日",
                    setHeight,
                    imagePath,
                    weeklyMenuData,
                    dateByWeekday["日曜日"],
                    weeklyDate[6],
                    isPopupUpdatePromotion.value),
                floatActionButton(setHeight, context),
              ],
            ),
          ],
        ),
      );
    }
  }

  ///
  /// 月曜から日曜までのレシピ表示領域を作成
  ///
  /// [weekdayText] 画面表示する曜日のテキスト情報
  /// [setHeight] 表示領域の高さ指定
  /// [imagePath] アイコン表示用パス
  /// [weeklyMenuData] 画面表示用レシピデータ
  /// [displayDate] 画面表示用日付("yyyy/mm/dd")
  /// [weeklyDate] 動作確認用日付("yyyymmdd")
  /// [isPopupUpdatePromotion] 更新促進画面表示判定フラグ
  ///
  /// 戻り値::月曜から日曜までのレシピ表示領域ウィジェット
  ///
  Widget _cardWidget(weekdayText, setHeight, imagePath, weeklyMenuData,
      displayDate, weeklyDate, isPopupUpdatePromotion) {
    String mainRecipes = "";
    String subRecipes = "";
    String dessertRecipes = "";

    // 更新促進画面表示時は、ヘッダー情報のみ表示する(レシピデータが空のため後続レシピ情報取得処理でエラーとなる)
    if (isPopupUpdatePromotion) {
      return SizedBox(
          height: setHeight,
          child: Card(
            child: Column(
              children: [
                _createCardHeader(weekdayText, displayDate),
              ],
            ),
          ));
    }

    if (weeklyMenuData.value != null && !weeklyMenuData.value.isEmpty) {
      // TODO 将来の機能にて、朝食タブ、昼食タブ、夕食タブを実装する予定
      //      現状は、夕食メニューのみを表示する想定のため、dinnerをキーに指定する
      mainRecipes = weeklyMenuData.value[weeklyDate]["dinner"]["main"];
      subRecipes = weeklyMenuData.value[weeklyDate]["dinner"]["sub"];
      dessertRecipes = weeklyMenuData.value[weeklyDate]["dinner"]["dessert"];

      return SizedBox(
          height: setHeight,
          child: Card(
            child: Column(
              children: [
                _createCardHeader(weekdayText, displayDate),
                _createCardBody(imagePath, weeklyMenuData, mainRecipes,
                    subRecipes, dessertRecipes),
              ],
            ),
          ));
    }
    return Container();
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

  ///
  /// 各曜日タイルのメニュー表示箇所を作成する
  ///
  /// [imagePath] 曜日テキスト
  /// [weeklyMenuData] 日付テキスト
  /// [mainRecipes] メイン料理メニュー名
  /// [subRecipes] サブ料理メニュー名
  /// [dessertRecipes] 曜日テキスト
  ///
  /// 戻り値::各曜日タイルのヘッダ
  ///
  Widget _createCardBody(
      imagePath, weeklyMenuData, mainRecipes, subRecipes, dessertRecipes) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _titleAndRecipeName(imagePath["main"], "主菜レシピ名",
              weeklyMenuData.value == null ? "" : mainRecipes),
          const SizedBox(
            height: 10.0,
          ),
          _titleAndRecipeName(imagePath["sub"], "副菜レシピ名",
              weeklyMenuData.value == null ? "" : subRecipes),
          const SizedBox(
            height: 10.0,
          ),
          _titleAndRecipeName(imagePath["dessert"], "デザートレシピ名",
              weeklyMenuData.value == null ? "" : dessertRecipes),
        ],
      ),
    );
  }

  ///
  /// 各曜日カード内で表示するメニューアイコンを設定する
  ///
  Map<String, String> _setImage() {
    return {
      "main": "assets/images/main.png",
      "sub": "assets/images/sub.png",
      "dessert": "assets/images/dessert.png",
    };
  }

  ///
  /// 更新促進画面を表示する
  ///
  /// [context] build時のcontext
  ///
  void _executePopupUpdatePromotion(context, ref) {
    isExecutedPopupUpdatePromotion = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 画面が描画された後、モーダルダイアログを表示
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const UpdatePromotionWeeklyRecipeModalPage();
          });
      ref
          .read(dataUpdatePromotionNotifierProvider.notifier)
          .changeIsNeedCreateWeeklyMenu();

      ref
          .read(weeklyRecipesDataNotifierProvider.notifier)
          .updateWeeklyMenuState();

      setState(() {});
    });
  }
}
