import 'package:flutter/material.dart';
import 'package:recipe_suggestion/data/recipe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:recipe_suggestion/domain/repository/firebase.dart';
part 'recipes_data.g.dart';

@riverpod

// Notifierクラス
class RecipesDataNotifier extends _$RecipesDataNotifier {
  @override
  // 初期化処理
  Future<List<Recipe>?> build() async {
    debugPrint("666666666666666666666666666");

    return await _fetchAllRecipesData();
  }

  // レシピデータ更新処理
  fetchRecipeDataState() async {
    state = AsyncValue.data(await _fetchAllRecipesData());
    debugPrint("777777777777777777777777777");
  }

  // レシピデータを全件取得
  Future<List<Recipe>?> _fetchAllRecipesData() async {
    debugPrint("888888888888888888888888888888");
    Firebase firebase = Firebase();
    List<Recipe>? data = await firebase.searchAllRecipes();
    debugPrint("999999999999999999999999999999");

    return data;
  }
}
