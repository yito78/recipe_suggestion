import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/data/recipe.dart';
import 'package:recipe_suggestion/provider/categories_data.dart';
import 'package:recipe_suggestion/provider/recipes_data.dart';
import 'package:recipe_suggestion/utils/log.dart';
import 'package:recipe_suggestion/view/drawer_component.dart';
import 'package:recipe_suggestion/view/recipe_list_page.dart';
import 'package:recipe_suggestion/view/weekly_recipe_page.dart';

/// 機能一覧画面生成クラス
class FunctionListPage extends ConsumerStatefulWidget {
  const FunctionListPage({super.key});

  @override
  ConsumerState<FunctionListPage> createState() => _FunctionListPageState();
}

class _FunctionListPageState extends ConsumerState<FunctionListPage> {
  @override
  Widget build(BuildContext context) {
    _outputAccessLog();

    // recipesデータの監視
    final recipesWatch = ref.watch(recipesDataNotifierProvider);
    // categoriesデータの監視
    final categoriesWatch = ref.watch(categoriesDataNotifierProvider);

    // recipesデータからデータ抽出
    AsyncValue<List<Recipe>?> fetchedRecipesData = recipesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      _outputErrorLog(e, s);
      return AsyncValue.error(e, s);
    }, loading: () {
      return const AsyncValue.loading();
    });
    final recipes = fetchedRecipesData.value;

    // categoriesデータからデータ抽出
    AsyncValue<List<Map<String, dynamic>>?> fetchedCategoriesData =
        categoriesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      _outputErrorLog(e, s);
      return AsyncValue.error(e, s);
    }, loading: () {
      return const AsyncValue.loading();
    });
    final categories = fetchedCategoriesData.value;

    // 1週間のレシピ一覧画面の活性状態を判定(各カテゴリに1件以上データ登録あれば、活性化)
    Map<String, dynamic> validationResultMap =
        _selectInvalidCategoryIdAndIsActivated(recipes, categories);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("機能一覧")),
          automaticallyImplyLeading: false,
        ),
        endDrawer: const DrawerComponent(),
        body: Column(
          children: [
            _createButton(context, const WeeklyRecipePage(),
                const Text("1週間のレシピ一覧"), validationResultMap["isActivated"]),
            _createButton(
                context, const RecipeListPage(), const Text("登録レシピ一覧")),
            validationResultMap["isActivated"]
                ? Container()
                : _displayPromoteRegisterMessage(
                    validationResultMap["validCategoryNames"]),
          ],
        ),
        // firestoreデータ再取得ボタン
        floatingActionButton:
            _floatingActionButton(context, fetchedRecipesData, ref),
      ),
    );
  }

  ///
  /// ボタンWidget作成
  ///
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  /// [text] 表示されるボタン名
  /// [isActivated] ボタン活性状態制御フラグ(true: 活性状態、false: 非活性状態)
  ///
  /// 戻り値::ElevatedButton
  ///
  Widget _createButton(context, page, text, [bool isActivated = true]) {
    // 横幅定義用データ
    var screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Center(
        child: SizedBox(
          width: screenSize.width * 0.8,
          child: ElevatedButton(
              onPressed: isActivated ? () => _navigate(context, page) : null,
              child: text),
        ),
      ),
    );
  }

  ///
  /// 画面遷移処理
  ///
  /// [context] build時のcontext
  /// [page] 遷移先のページ
  ///
  /// 戻り値::なし
  ///
  _navigate(context, page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  ///
  /// firestoreからのデータ再取得ボタン
  /// 画面描画時、firestoreからデータ取得失敗時を想定し、ボタン設置
  ///
  /// [context] BuilderContextオブジェクト
  /// [fetchedRecipesData] firestoreデータ
  /// [ref] recipeデータの監視データ
  ///
  /// 戻り値::FloatingActionButton Widget
  ///
  Widget _floatingActionButton(context, fetchedRecipesData, ref) {
    return FloatingActionButton(
      onPressed: () async {
        final recipeNotifier = ref.read(recipesDataNotifierProvider.notifier);
        recipeNotifier.fetchRecipeDataState();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('データを再取得しました'),
          ),
        );
      },
      child: const Icon(Icons.refresh),
    );
  }

  ///
  /// 機能にアクセスされたことをアナリティクスログとして出力する
  ///
  _outputAccessLog() {
    Log log = Log();
    log.accessLog(runtimeType.toString());
  }

  ///
  /// エラー発生内容をアナリティクスログとして出力する
  ///
  /// [e] エラークラス
  /// [s] スタックトレース
  ///
  _outputErrorLog(e, s) {
    Log log = Log();
    log.errorLog(runtimeType.toString(), e, s);
  }

  ///
  /// 1週間レシピ機能の利用判定を実施
  ///   各カテゴリにレシピデータが1件以上登録されていれば、利用可能
  ///
  /// [recipes] レシピデータ
  /// [categories] カテゴリデータ
  ///
  ///　戻り値::true 利用可能
  /// selectInvalidCategoryIdAndIsActivated
  Map<String, dynamic> _selectInvalidCategoryIdAndIsActivated(
      List<Recipe>? recipes, List<Map<String, dynamic>>? categories) {
    Map<int, dynamic> checkerByCategoryId = {};
    List<String> validCategoryNames = [];
    Map<String, dynamic> resultData = {
      "isActivated": false,
      "validCategoryNames": validCategoryNames,
    };

    // データバリデーション
    if (recipes == null || categories == null) {
      return resultData;
    }

    // カテゴリ種別を抽出し、後続処理で各カテゴリ種別にデータが存在するかチェックさせる
    for (var category in categories) {
      checkerByCategoryId[category["category_id"]] = "";
    }

    // 各レシピデータ内のカテゴリ値を元に、カテゴリチェッカーハッシュに証跡を残す
    for (var data in recipes) {
      checkerByCategoryId[data.category] = "check";
    }

    // 各カテゴリ種別にデータがない場合、不正カテゴリ種別としてリスト管理する
    for (var category in categories) {
      if (checkerByCategoryId[category["category_id"]] != "check") {
        validCategoryNames.add(category["name"]);
      }
    }

    // 不正カテゴリ種別がある場合、利用不可の判定
    if (validCategoryNames.isNotEmpty) {
      resultData["validCategoryNames"] = validCategoryNames;
    } else {
      resultData["isActivated"] = true;
    }

    return resultData;
  }

  ///
  /// レシピデータの登録を促すメッセージを表示する
  ///
  /// [validCategoryId] 不正なカテゴリ種別
  ///
  /// 戻り値::メッセージ
  ///
  Widget _displayPromoteRegisterMessage(List<String> validCategoryNames) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Text(
          "※登録レシピ一覧機能より、以下カテゴリ種別のレシピデータを登録してください\n\nカテゴリ種別: ${validCategoryNames.toString()}",
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
