import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/data/recipe.dart';
import 'package:recipe_suggestion/provider/login_user.dart';
import 'package:recipe_suggestion/provider/recipes_data.dart';
import 'package:recipe_suggestion/utils/log.dart';
import 'package:recipe_suggestion/view/drawer_component.dart';
import 'package:recipe_suggestion/view/import_csv_page.dart';
import 'package:recipe_suggestion/view/recipe_list_page.dart';
import 'package:recipe_suggestion/view/weekly_recipe_page.dart';

/// 機能一覧画面生成クラス
class FunctionListPage extends ConsumerWidget {
  const FunctionListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _outputAccessLog();

    // recipesデータの監視
    final recipesWatch = ref.watch(recipesDataNotifierProvider);

    // recipesデータからデータ抽出
    AsyncValue<List<Recipe>> fetchedRecipesData = recipesWatch.when(data: (d) {
      return AsyncValue.data(d);
    }, error: (e, s) {
      _outputErrorLog(e, s);
      return AsyncValue.error(e, s);
    }, loading: () {
      return const AsyncValue.loading();
    });

    // ユーザログイン状況監視
    final signedInUserWatch = ref.watch(userProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("機能一覧")),
          automaticallyImplyLeading: false,
        ),
        // 現状drawerにはログアウト機能のみのため、ログイン状態であれば表示、そうでなければ非表示とする
        endDrawer:
            signedInUserWatch.value != null ? const DrawerComponent() : null,
        body: Column(
          children: [
            // 部分的に再レンダリング
            Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final recipeWatch = ref.watch(recipesDataNotifierProvider);
              List<dynamic> list = [];
              recipeWatch.value?.forEach((element) {
                list.add(element);
              });
              if (list.isEmpty) {
                return _button(context, const WeeklyRecipePage(),
                    const Text("1週間のレシピ一覧"), false);
              } else {
                return _button(
                    context, const WeeklyRecipePage(), const Text("1週間のレシピ一覧"));
              }
            }),
            _button(context, const RecipeListPage(), const Text("登録レシピ一覧")),
            _button(context, const ImportCsvPage(), const Text("CSVファイルデータ登録")),
          ],
        ),
        // firestoreデータ再取得ボタン
        floatingActionButton:
            _floatingActionButton(context, fetchedRecipesData, ref),
      ),
    );
  }

  //
  // ボタンWidget作成
  //
  // context::build時のcontext
  // page::遷移先のページ
  // text::表示されるボタン名
  // isActivated::ボタン活性状態制御フラグ(true: 活性状態、false: 非活性状態)
  //
  // 戻り値::ElevatedButton
  //
  Widget _button(context, page, text, [bool isActivated = true]) {
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
  // firestoreからのデータ再取得ボタン
  // 画面描画時、firestoreからデータ取得失敗時を想定し、ボタン設置
  //
  // context::BuilderContextオブジェクト
  // fetchedRecipesData::firestoreデータ
  // ref::recipeデータの監視データ
  //
  // 戻り値::FloatingActionButton Widget
  //
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
