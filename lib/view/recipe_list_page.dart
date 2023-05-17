import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_suggestion/utils/log.dart';

import '../provider/recipes_data.dart';

class RecipeListPage extends ConsumerWidget {
  const RecipeListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _outputAccessLog();

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

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("登録済レシピ一覧")),
      ),
      body: ListView.builder(
          itemCount: recipeList.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("${recipeList[index]["name"]}"),
                ),
                // ボタンオブジェクトを右寄せするため
                Expanded(child: SizedBox()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text("編集"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text("削除"),
                  ),
                ),
              ],
            );
          }),
    );
    // return const Text("登録済みレシピ一覧画面");
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
